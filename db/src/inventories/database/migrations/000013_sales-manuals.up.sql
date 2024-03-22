-- シーケンス
DROP SEQUENCE IF EXISTS inventories.billing_no_seed;
CREATE SEQUENCE inventories.billing_no_seed START 1;

DROP SEQUENCE IF EXISTS inventories.deposit_no_seed;
CREATE SEQUENCE inventories.deposit_no_seed START 1;

DROP SEQUENCE IF EXISTS inventories.receiving_no_seed;
CREATE SEQUENCE inventories.receiving_no_seed START 1;

DROP SEQUENCE IF EXISTS inventories.shipping_no_seed;
CREATE SEQUENCE inventories.shipping_no_seed START 1;

-- 入金充当
-- Create Function
CREATE OR REPLACE PROCEDURE inventories.apply_deposit(i_costomer_id text, i_created_by text) AS $$
DECLARE
  deposit RECORD;
  billing RECORD;
  t_applied_amount numeric;
  t_billing_status inventories.billing_status;
BEGIN
  -- 残額のある入金データでループ
  FOR deposit IN SELECT * FROM inventories.deposits
  WHERE costomer_id = i_costomer_id AND remaining_amount > 0 LOOP

    -- 金額確定済みの残額のある請求データでループ
    FOR billing IN SELECT * FROM inventories.bills
    WHERE costomer_id = i_costomer_id AND remaining_amount > 0 AND freeze_changed_timestamp IS NOT NULL
    ORDER BY deposit_limit_date LOOP

      -- 充当金額/請求状況の算出(請求残/入金残の小さい方)
      IF billing.remaining_amount > deposit.remaining_amount THEN
        t_applied_amount = deposit.remaining_amount;
        t_billing_status = 'PART_OF_DEPOSITED';
      ELSE
        t_applied_amount = billing.remaining_amount;
        t_billing_status = 'COMPLETED';
      END IF;

      INSERT INTO inventories.deposit_appropriations VALUES (
        billing.billing_id,
        deposit.deposit_id,
        t_applied_amount,
        default,
        default,
        i_created_by,
        i_created_by
      );

      UPDATE inventories.deposits
      SET applied_amount = applied_amount + t_applied_amount, updated_by = i_created_by
      WHERE deposit_id = deposit.deposit_id;

      UPDATE inventories.bills
      SET applied_amount = applied_amount + t_applied_amount, billing_status = t_billing_status, updated_by = i_created_by
      WHERE billing_id = billing.billing_id;
    END LOOP;
  END LOOP;
  RETURN;
END;
$$ LANGUAGE plpgsql;


-- 請求:登録「前」処理
--  導出属性の算出:登録時のみ(請求ID)
--  導出属性の算出(残額/変更凍結日時/請求状況)
--  有効桁数調整(請求金額/充当済金額)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.bills_pre_process() RETURNS TRIGGER AS $$
BEGIN
  -- 導出属性の算出:登録時のみ(請求ID)
  IF (TG_OP = 'INSERT') THEN
    NEW.billing_id:='BL-'||to_char(nextval('inventories.billing_no_seed'),'FM0000000');
  END IF;

  -- 有効桁数調整(請求金額/充当済金額)
  NEW.billing_amount = ROUND(NEW.billing_amount, 2);
  NEW.applied_amount = ROUND(NEW.applied_amount, 2);

--  導出属性の算出(残額)
  NEW.remaining_amount = ROUND(NEW.billing_amount - NEW.applied_amount, 2);

  -- 導出属性の算出(変更凍結日時/請求状況)
  IF (OLD.amount_confirmed_date IS NULL AND NEW.amount_confirmed_date IS NOT NULL) THEN
    NEW.freeze_changed_timestamp:=current_timestamp;
    NEW.billing_status = 'CONFIRMED';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.bills
  FOR EACH ROW
EXECUTE PROCEDURE inventories.bills_pre_process();


-- 請求:登録「後」処理
--  別テーブルの作成(入金充当)
--  導出属性の算出(請求状況)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.apply_deposit_from_bill() RETURNS TRIGGER AS $$
BEGIN
  IF (OLD.amount_confirmed_date IS NULL AND NEW.amount_confirmed_date IS NOT NULL) THEN
    CALL inventories.apply_deposit(NEW.costomer_id, NEW.updated_by);-- FIXME:
  END IF;

  -- 導出属性の算出(請求状況)
  IF NEW.remaining_amount = 0 THEN
    NEW.billing_status = 'COMPLETED';

  ELSIF NEW.applied_amount > 0 THEN
    NEW.billing_status = 'PART_OF_DEPOSITED';

  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  AFTER INSERT OR UPDATE
  ON inventories.bills
  FOR EACH ROW
EXECUTE PROCEDURE inventories.apply_deposit_from_bill();


-- 請求登録/金額更新
-- Create Function
CREATE OR REPLACE FUNCTION inventories.upsert_bills_for_cutoff_date(
  i_costomer_id text,
  i_cut_off_date date,
  i_deposit_limit_date date,
  i_variable_amount numeric,
  i_create_by text
) RETURNS text AS $$
DECLARE
  rec RECORD;
  r_billing_id text;
BEGIN
  SELECT * INTO rec FROM inventories.bills
    WHERE  costomer_id = i_costomer_id AND cut_off_date = i_cut_off_date AND deposit_limit_date = i_deposit_limit_date
    FOR UPDATE;

  IF rec IS NULL THEN
    INSERT INTO inventories.bills VALUES (
      default,
      i_costomer_id,
      i_cut_off_date,
      i_deposit_limit_date,
      i_variable_amount,
      default,
      default,
      default,
      NULL,
      NULL,
      default,
      default,
      i_create_by,
      i_create_by
    ) RETURNING billing_id INTO r_billing_id;
    RETURN r_billing_id;

  ELSE
    UPDATE inventories.bills
    SET billing_amount = rec.billing_amount + i_variable_amount,
        updated_by = i_create_by
    WHERE  billing_id = rec.billing_id;
    RETURN rec.billing_id;
  END IF;

END;
$$ LANGUAGE plpgsql;


-- 請求:チェック制約
--  属性相関チェック制約(締日付/入金期限日付)

-- Create Constraint
ALTER TABLE inventories.bills DROP CONSTRAINT IF EXISTS deposit_limit_date_check;
ALTER TABLE inventories.bills ADD CONSTRAINT deposit_limit_date_check CHECK (
  cut_off_date < deposit_limit_date
);

-- 請求:チェック制約
--  属性相関チェック制約(締日付/金額確定日付)

-- Create Constraint
ALTER TABLE inventories.bills DROP CONSTRAINT IF EXISTS amount_confirmed_date_check;
ALTER TABLE inventories.bills ADD CONSTRAINT amount_confirmed_date_check CHECK (
  cut_off_date < amount_confirmed_date
);


-- 入金:登録「前」処理
--  導出属性の算出:登録時のみ(入金ID)
--  導出属性の算出(残額)
--  有効桁数調整(入金金額/充当済金額)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.deposits_pre_process() RETURNS TRIGGER AS $$
BEGIN
  -- 導出属性の算出:登録時のみ(入金ID)
  IF (TG_OP = 'INSERT') THEN
    NEW.deposit_id:='DP-'||to_char(nextval('inventories.deposit_no_seed'),'FM0000000');
  END IF;

  -- 有効桁数調整(入金金額/充当済金額)
  NEW.deposit_amount = ROUND(NEW.deposit_amount, 2);
  NEW.applied_amount = ROUND(NEW.applied_amount, 2);

--  導出属性の算出(残額)
  NEW.remaining_amount = ROUND(NEW.deposit_amount - NEW.applied_amount, 2);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.deposits
  FOR EACH ROW
EXECUTE PROCEDURE inventories.deposits_pre_process();


-- 入金:登録「後」処理
--  別テーブルの作成(入金充当/売掛変動履歴)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.apply_deposit_from_deposit() RETURNS TRIGGER AS $$
BEGIN
  --  1.入金充当 INFO:
  CALL inventories.apply_deposit(NEW.costomer_id, NEW.updated_by);-- FIXME:

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  2.売掛変動履歴 INFO:
  INSERT INTO inventories.receivable_histories
  VALUES (
    default,
    NEW.deposit_date,
    NEW.operation_timestamp,
    NEW.costomer_id,
    - NEW.deposit_amount,
    'DEPOSIT',
    NEW.deposit_instruction_no,
    NULL,
    NEW.deposit_id,
    default,
    default,
    NEW.created_by,
    NEW.created_by
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  AFTER INSERT
  ON inventories.deposits
  FOR EACH ROW
EXECUTE PROCEDURE inventories.apply_deposit_from_deposit();


-- 月次売掛金サマリ:登録「前」処理
--  導出属性の算出(残高)
--  有効桁数調整(月初残高/売上金額/入金金額/その他金額)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.month_receivables_pre_process() RETURNS TRIGGER AS $$
BEGIN
  --  有効桁数調整(月初残高/購入金額/支払金額/その他金額)
  NEW.init_balance = ROUND(NEW.init_balance, 2);
  NEW.sales_amount = ROUND(NEW.sales_amount, 2);
  NEW.deposit_amount = ROUND(NEW.deposit_amount, 2);
  NEW.other_amount = ROUND(NEW.other_amount, 2);
  -- 導出属性の算出(在庫数量)
  NEW.present_balance = NEW.init_balance + NEW.sales_amount - NEW.deposit_amount + NEW.other_amount;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.month_accounts_receivables
  FOR EACH ROW
EXECUTE PROCEDURE inventories.month_receivables_pre_process();


-- 現在売掛金サマリ:登録「前」処理
--  有効桁数調整(残高)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.current_receivables_pre_process() RETURNS TRIGGER AS $$
BEGIN
  --  有効桁数調整(残高)
  NEW.present_balance = ROUND(NEW.present_balance, 2);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.current_accounts_receivables
  FOR EACH ROW
EXECUTE PROCEDURE inventories.current_receivables_pre_process();


-- 売掛変動履歴:チェック制約
--  属性相関チェック制約(売掛変動種類/変動金額/請求番号/入金番号)

-- Create Constraint
ALTER TABLE inventories.receivable_histories DROP CONSTRAINT IF EXISTS receivable_histories_receivable_type_check;
ALTER TABLE inventories.receivable_histories ADD CONSTRAINT receivable_histories_receivable_type_check CHECK (
  CASE
    -- 売掛変動種類が「販売売上」の場合、変動金額が0より大きい値であること
    WHEN receivable_type = 'SELES' AND variable_amount <= 0.00 THEN FALSE
    -- 売掛変動種類が「売上返品」「入金」の場合、変動金額が0より小さい値であること
    WHEN receivable_type = 'SALES_RETURN' AND variable_amount >= 0.00 THEN FALSE
    WHEN receivable_type = 'DEPOSIT' AND variable_amount >= 0.00 THEN FALSE
    -- 売掛変動種類が「入金」の場合、請求番号がNULLであること
    WHEN receivable_type = 'DEPOSIT' AND billing_id IS NOT NULL THEN FALSE
    -- 売掛変動種類が「販売売上」「売上返品」「その他取引」の場合、請求番号がNULLではないこと
    WHEN receivable_type = 'SELES' AND billing_id IS NULL THEN FALSE
    WHEN receivable_type = 'SALES_RETURN' AND billing_id IS NULL THEN FALSE
    WHEN receivable_type = 'OTHER' AND billing_id IS NULL THEN FALSE
    -- 売掛変動種類が「入金」の場合、入金番号がNULLではないこと
    WHEN receivable_type = 'DEPOSIT' AND deposit_id IS NULL THEN FALSE
    -- 売掛変動種類が「販売売上」「売上返品」「その他取引」の場合、入金番号がNULLであること
    WHEN receivable_type = 'SELES' AND deposit_id IS NOT NULL THEN FALSE
    WHEN receivable_type = 'SALES_RETURN' AND deposit_id IS NOT NULL THEN FALSE
    WHEN receivable_type = 'OTHER' AND deposit_id IS NOT NULL THEN FALSE
    ELSE TRUE
  END
);


-- 売掛変動履歴:登録「前」処理
--  有効桁数調整(変動金額)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.receivable_histories_pre_process() RETURNS TRIGGER AS $$
BEGIN
  --  有効桁数調整(変動金額)
  NEW.variable_amount = ROUND(NEW.variable_amount, 2);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.receivable_histories
  FOR EACH ROW
EXECUTE PROCEDURE inventories.receivable_histories_pre_process();


-- 売掛変動履歴:登録「後」処理
--  別テーブル登録/更新(月次売掛金サマリ/現在売掛金サマリ)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.upsert_accounts_receivables() RETURNS TRIGGER AS $$
DECLARE
  yyyymm text:=to_char(NEW.business_date, 'YYYYMM');

  t_init_balance numeric;
  t_sales_amount numeric;
  t_deposit_amount numeric;
  t_other_amount numeric;

  recent_rec RECORD; --検索結果レコード(現在年月)
  last_rec RECORD;--検索結果レコード(過去最新年月)
  rec RECORD;
BEGIN
--  1.月次売掛金サマリ INFO:

  -- 1.1.現在年月データの取得
  SELECT * INTO recent_rec
    FROM inventories.month_accounts_receivables
    WHERE costomer_id = NEW.costomer_id AND year_month = yyyymm
    FOR UPDATE;

  -- 1.2.月初残高/購入金額/支払金額/その他金額の算出
  IF recent_rec IS NULL THEN
    -- 現在年月データが存在しないケース
    -- 過去最新残高の取得
    SELECT * INTO last_rec
      FROM inventories.month_accounts_receivables
      WHERE costomer_id = NEW.costomer_id AND year_month < yyyymm
      ORDER BY year_month DESC
      LIMIT 1;
    -- 過去最新在庫数が取得できた場合は月初残高に設定
    t_init_balance:=CASE WHEN last_rec IS NULL THEN 0.00 ELSE last_rec.present_balance END;
    t_sales_amount:=0.00;
    t_deposit_amount:=0.00;
    t_other_amount:=0.00;
  ELSE
    -- 現在年月データが存在するケース
    t_init_balance:=recent_rec.init_balance;
    t_sales_amount:=recent_rec.sales_amount;
    t_deposit_amount:=recent_rec.deposit_amount;
    t_other_amount:=recent_rec.other_amount;
  END IF;

  -- 1.3.取引数量の計上(売掛変動種類により判断)
  IF NEW.receivable_type='SELES' OR NEW.receivable_type='SALES_RETURN' THEN
    t_sales_amount:=t_sales_amount + NEW.variable_amount;
  ELSIF NEW.receivable_type='DEPOSIT' THEN
    t_deposit_amount:=t_deposit_amount - NEW.variable_amount;
  ELSIF NEW.receivable_type='OTHER' THEN
    t_other_amount:=t_other_amount + NEW.variable_amount;
  END IF;

  -- 1.4.登録/更新
  IF recent_rec IS NULL THEN
    -- 現在年月データが存在しないケース
    INSERT INTO inventories.month_accounts_receivables VALUES (
      NEW.costomer_id,
      yyyymm,
      t_init_balance,
      t_sales_amount,
      t_deposit_amount,
      t_other_amount,
      default,
      default,
      default,
      NEW.created_by,
      NEW.created_by
    );
  ELSE
    -- 現在年月データが存在するケース
    UPDATE inventories.month_accounts_receivables
    SET sales_amount = t_sales_amount,
        deposit_amount = t_deposit_amount,
        other_amount = t_other_amount
    WHERE costomer_id = NEW.costomer_id AND year_month = yyyymm;
  END IF;

  -- 1.5.現在年月以降のデータ更新(存在する場合)
  FOR rec IN SELECT * FROM inventories.month_accounts_receivables
    WHERE costomer_id = NEW.costomer_id AND year_month > yyyymm LOOP

    UPDATE inventories.month_accounts_receivables
    SET init_balance = rec.init_balance + NEW.variable_amount
    WHERE costomer_id = NEW.costomer_id AND year_month = rec.year_month;
  END LOOP;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

--  2.現在売掛金サマリ INFO:

  -- 2.1.最新データの取得
  SELECT * INTO recent_rec
    FROM inventories.current_accounts_receivables
    WHERE costomer_id = NEW.costomer_id
    FOR UPDATE;

  -- 2.2.登録/更新
  IF recent_rec IS NULL THEN
    -- 最新データが存在しないケース
    INSERT INTO inventories.current_accounts_receivables VALUES (
      NEW.costomer_id,
      NEW.variable_amount,
      default,
      default,
      NEW.created_by,
      NEW.created_by
    );
  ELSE
    -- 最新データが存在するケース
    UPDATE inventories.current_accounts_receivables
    SET present_balance = recent_rec.present_balance + NEW.variable_amount
    WHERE costomer_id = NEW.costomer_id;
  END IF;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  AFTER INSERT
  ON inventories.receivable_histories
  FOR EACH ROW
EXECUTE PROCEDURE inventories.upsert_accounts_receivables();


-- 受注得意先取得
-- Create Function
CREATE OR REPLACE FUNCTION inventories.costomer_id_for_receivings(i_receiving_id text) RETURNS text AS $$
BEGIN
  RETURN(SELECT costomer_id FROM inventories.receivings WHERE receiving_id = i_receiving_id);
END;
$$ LANGUAGE plpgsql;


-- 受注:登録「前」処理
--  導出属性の算出:登録時のみ(受注ID)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.receivings_pre_process() RETURNS TRIGGER AS $$
BEGIN
  -- 導出属性の算出:登録時のみ(受注ID)
  IF (TG_OP = 'INSERT') THEN
    NEW.receiving_id:='RO-'||to_char(nextval('inventories.receiving_no_seed'),'FM0000000');
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.receivings
  FOR EACH ROW
EXECUTE PROCEDURE inventories.receivings_pre_process();


-- 受注時売価取得
-- Create Function
CREATE OR REPLACE FUNCTION inventories.selling_price_for_receivings(i_receiving_id text, i_product_id text) RETURNS numeric AS $$
BEGIN
  RETURN(SELECT selling_price FROM inventories.receiving_details WHERE receiving_id = i_receiving_id AND product_id = i_product_id);
END;
$$ LANGUAGE plpgsql;


-- 発注明細:登録「前」処理
--  登録時初期化(出庫数量/キャンセル数量)
--  導出属性の算出:登録時のみ(売価/想定原価/想定利益率)
--  導出属性の算出(残数量)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.receiving_details_pre_process() RETURNS TRIGGER AS $$
DECLARE
  t_order_date date;
  t_days_to_arrive integer;
BEGIN
  IF (TG_OP = 'INSERT') THEN
    --  登録時初期化(出庫数量/キャンセル数量)
    NEW.shipping_quantity:=0;
    NEW.cancel_quantity:=0;

--  導出属性の算出:登録時のみ(売価)
    IF NEW.selling_price IS NULL THEN
      NEW.selling_price = inventories.selling_price_for_products(NEW.product_id);
    ELSE
      NEW.selling_price = ROUND(NEW.selling_price, 2);
    END IF;

--  導出属性の算出:登録時のみ(想定原価/想定利益率)
    NEW.estimate_cost_price = inventories.cost_price_for_inventory(NEW.product_id);
    NEW.estimate_profit_rate = inventories.calc_profit_rate(NEW.selling_price, NEW.estimate_cost_price);
  END IF;

  --  導出属性の算出(残数量)
  NEW.remaining_quantity:=NEW.receiving_quantity - NEW.shipping_quantity - NEW.cancel_quantity;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.receiving_details
  FOR EACH ROW
EXECUTE PROCEDURE inventories.receiving_details_pre_process();


-- 出荷得意先取得
-- Create Function
CREATE OR REPLACE FUNCTION inventories.costomer_id_for_shippings(i_sipping_id text) RETURNS text AS $$
BEGIN
  RETURN(SELECT costomer_id FROM inventories.shippings WHERE sipping_id = i_sipping_id);
END;
$$ LANGUAGE plpgsql;


-- 出荷:チェック制約
--  テーブル相関チェック制約(請求(締日付/入金期限日付)の金額未確定チェック)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.is_before_freeze_deposit_amounts(i_costomer_id text, i_cut_off_date date, i_deposit_limit_date date, operation_timestamp timestamp) RETURNS boolean AS $$
BEGIN
  -- 入金金額確定日時よりも処理日時が前である場合にTrue
  RETURN(SELECT freeze_changed_timestamp > operation_timestamp FROM inventories.bills
    WHERE  costomer_id = i_costomer_id AND cut_off_date = i_cut_off_date AND deposit_limit_date = i_deposit_limit_date);
END;
$$ LANGUAGE plpgsql;

-- Create Constraint
ALTER TABLE inventories.shippings DROP CONSTRAINT IF EXISTS shippings_billing_id_check;
ALTER TABLE inventories.shippings ADD CONSTRAINT shippings_billing_id_check CHECK (
  inventories.is_before_freeze_deposit_amounts(costomer_id, cut_off_date,deposit_limit_date, operation_timestamp)
);


-- 出荷:登録「前」処理
--  導出属性の算出:登録時のみ(出荷ID/締日付/入金期限日付/請求番号)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.shippings_pre_process() RETURNS TRIGGER AS $$
DECLARE
  rec RECORD;
BEGIN
  IF (TG_OP = 'INSERT') THEN
    -- 導出属性の算出:登録時のみ(出荷ID)
    NEW.sipping_id:='SP-'||to_char(nextval('inventories.shipping_no_seed'),'FM0000000');

    -- 導出属性の算出:登録時のみ(締日付/入金期限日付)
    -- 両項目の設定がいずれも設定がない場合に算出される。(片方だけ設定がある場合はNULL制約エラー)
    IF NEW.cut_off_date IS NULL AND NEW.deposit_limit_date IS NULL THEN
      rec = inventories.calc_deposit_deadline(NEW.costomer_id, NEW.sipping_date);
      NEW.cut_off_date = rec.cut_off_date;
      NEW.deposit_limit_date = rec.deposit_date;
    END IF;

    -- 導出属性の算出:登録時のみ(請求番号)
    NEW.billing_id = inventories.upsert_bills_for_cutoff_date(NEW.costomer_id, NEW.cut_off_date, NEW.deposit_limit_date, 0, NEW.created_by);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.shippings
  FOR EACH ROW
EXECUTE PROCEDURE inventories.shippings_pre_process();


-- 出荷時売価/原価取得
-- Create Function
CREATE OR REPLACE FUNCTION inventories.prices_for_shipping(
  i_sipping_id text,
  i_receiving_id text,
  i_product_id text,
  OUT selling_price numeric,
  OUT cost_price numeric
) AS $$
DECLARE
  rec record;
BEGIN
  SELECT * INTO rec FROM inventories.shipping_details WHERE sipping_id = i_sipping_id AND receiving_id = i_receiving_id AND product_id = i_product_id;
  selling_price = rec.selling_price;
  cost_price = rec.cost_price;
END;
$$ LANGUAGE plpgsql;


-- 出荷明細:チェック制約
--  属性相関チェック制約(出荷数量/返品数量)

-- Create Constraint
ALTER TABLE inventories.shipping_details DROP CONSTRAINT IF EXISTS shipping_details_return_quantity_check;
ALTER TABLE inventories.shipping_details ADD CONSTRAINT shipping_details_return_quantity_check CHECK (
  return_quantity <= shipping_quantity
);


-- 出荷明細:登録「前」処理
--  登録時初期化(返品数量)
--  導出属性の算出:登録時のみ(売価/原価/利益率)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.shipping_details_pre_process() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    --  登録時初期化(返品数量)
    NEW.return_quantity:=0;

--  導出属性の算出:登録時のみ(売価)
    IF NEW.selling_price IS NULL THEN
      NEW.selling_price = inventories.selling_price_for_receivings(NEW.receiving_id, NEW.product_id);
    ELSE
      NEW.selling_price = ROUND(NEW.selling_price, 2);
    END IF;

--  導出属性の算出:登録時のみ(原価/利益率)
    NEW.cost_price = inventories.cost_price_for_inventory(NEW.product_id);
    NEW.profit_rate = inventories.calc_profit_rate(NEW.selling_price, NEW.cost_price);

  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.shipping_details
  FOR EACH ROW
EXECUTE PROCEDURE inventories.shipping_details_pre_process();


-- 出荷明細:登録「後」処理
--  別テーブル登録/更新(受注明細/請求/売掛変動履歴/在庫変動履歴)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.shipping_post_process() RETURNS TRIGGER AS $$
DECLARE
  rec RECORD;
BEGIN

  SELECT * INTO rec FROM inventories.shippings WHERE sipping_id = NEW.sipping_id;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  1.受注明細 INFO:
  UPDATE inventories.receiving_details
  SET shipping_quantity = shipping_quantity + NEW.shipping_quantity,
      updated_by = NEW.created_by
  WHERE receiving_id = NEW.receiving_id AND product_id = NEW.product_id;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  2.請求 INFO:
  UPDATE inventories.bills
  SET billing_amount = billing_amount + NEW.shipping_quantity * NEW.selling_price,
      updated_by = NEW.created_by
  WHERE billing_id = rec.billing_id;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  3.売掛変動履歴 INFO:
  INSERT INTO inventories.receivable_histories
  VALUES (
    default,
    rec.sipping_date,
    rec.operation_timestamp,
    rec.costomer_id,
    NEW.shipping_quantity * NEW.selling_price,
    'SELES',
    NEW.shipping_detail_no,
    rec.billing_id,
    NULL,
    default,
    default,
    NEW.created_by,
    NEW.created_by
  );

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  4.在庫変動履歴 INFO:
  INSERT INTO inventories.inventory_histories
  VALUES (
    default,
    rec.sipping_date,
    rec.operation_timestamp,
    NEW.product_id,
    NEW.site_id,
    - NEW.shipping_quantity,
    - NEW.shipping_quantity * NEW.cost_price,
    'SELES',
    NEW.shipping_detail_no,
    default,
    default,
    NEW.created_by,
    NEW.created_by
  );

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  AFTER INSERT
  ON inventories.shipping_details
  FOR EACH ROW
EXECUTE PROCEDURE inventories.shipping_post_process();


-- 受注キャンセル指示:登録「後」処理
--  別テーブル変更(受注明細)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.update_receiving_cancel_quantity() RETURNS TRIGGER AS $$
BEGIN
  UPDATE inventories.receiving_details
  SET cancel_quantity = cancel_quantity + NEW.quantity,
      updated_by = NEW.created_by
  WHERE receiving_id = NEW.receiving_id AND product_id = NEW.product_id;

  return NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  BEFORE INSERT
  ON inventories.receiving_cancel_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.update_receiving_cancel_quantity();


-- 請求金額確定指示:登録「後」処理
--  別テーブル変更(請求)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.update_billing_comfirm_date() RETURNS TRIGGER AS $$
BEGIN
  UPDATE inventories.bills
  SET billing_status = 'CONFIRMED',
      amount_confirmed_date = NEW.business_date,
      updated_by = NEW.created_by
  WHERE billing_id = NEW.billing_id;

  return NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  BEFORE INSERT
  ON inventories.billing_confirm_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.update_billing_comfirm_date();


-- 出荷返品指示:登録「前」処理
--  導出属性の算出(売価/原価/締日付/入金期限日付/請求番号)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.shipping_return_instructions_pre_process() RETURNS TRIGGER AS $$
DECLARE
  i_costomer_id text;
  rec RECORD;
BEGIN

  --  導出属性の算出(売価/原価)
  rec = inventories.prices_for_shipping(NEW.sipping_id, NEW.receiving_id, NEW.product_id);
  IF NEW.selling_price IS NULL THEN
    NEW.selling_price = rec.selling_price;
  ELSE
    NEW.selling_price = ROUND(NEW.selling_price, 2);
  END IF;
  IF NEW.cost_price IS NULL THEN
    NEW.cost_price = rec.cost_price;
  ELSE
    NEW.cost_price = ROUND(NEW.cost_price, 2);
  END IF;

  -- 導出属性の算出(締日付/入金期限日付)
  -- 両項目の設定がいずれも設定がない場合に算出される。(片方だけ設定がある場合はNULL制約エラー)
  IF NEW.cut_off_date IS NULL AND NEW.deposit_limit_date IS NULL THEN
    SELECT costomer_id INTO i_costomer_id FROM inventories.shippings WHERE sipping_id = NEW.sipping_id;

    rec = inventories.calc_deposit_deadline(i_costomer_id, NEW.business_date);
    NEW.cut_off_date = rec.cut_off_date;
    NEW.deposit_limit_date = rec.deposit_date;
  END IF;

  -- 導出属性の算出(請求番号)
  NEW.billing_id = inventories.upsert_bills_for_cutoff_date(
    i_costomer_id,
    NEW.cut_off_date,
    NEW.deposit_limit_date,
    - NEW.quantity * NEW.selling_price,
    NEW.created_by
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT
  ON inventories.shipping_return_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.shipping_return_instructions_pre_process();


-- 出荷返品指示:登録「後」処理
--  別テーブル登録(出荷明細/売掛変動履歴/在庫変動履歴)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.shipping_return_instructions_post_process() RETURNS TRIGGER AS $$
DECLARE
  i_costomer_id text;
BEGIN

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  1.出荷明細 INFO:
  UPDATE inventories.shipping_details
  SET return_quantity = return_quantity + NEW.quantity,
      updated_by = NEW.created_by
  WHERE sipping_id = NEW.sipping_id AND receiving_id = NEW.receiving_id AND product_id = NEW.product_id;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  2.売掛変動履歴 INFO:
  SELECT costomer_id INTO i_costomer_id FROM inventories.shippings WHERE sipping_id = NEW.sipping_id;
  INSERT INTO inventories.receivable_histories
  VALUES (
    default,
    NEW.business_date,
    NEW.operation_timestamp,
    i_costomer_id,
    - NEW.quantity * NEW.selling_price,
    'SALES_RETURN',
    NEW.return_instruction_no,
    NEW.billing_id,
    default,
    default,
    default,
    NEW.created_by,
    NEW.created_by
  );

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  -- 3.在庫変動履歴 INFO:
  INSERT INTO inventories.inventory_histories
  VALUES (
    default,
    NEW.business_date,
    NEW.operation_timestamp,
    NEW.product_id,
    NEW.site_id,
    NEW.quantity,
    NEW.quantity * NEW.cost_price,
    'SALES_RETURN',
    NEW.return_instruction_no,
    default,
    default,
    NEW.created_by,
    NEW.created_by
  );

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  AFTER INSERT
  ON inventories.shipping_return_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.shipping_return_instructions_post_process();


-- 売掛金修正指示:登録「前」処理
--  有効桁数調整(変動金額)
--  導出属性の算出(締日付/入金期限日付/請求番号)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.correct_receivable_instructions_pre_process() RETURNS TRIGGER AS $$
DECLARE
  rec RECORD;
BEGIN

  --  有効桁数調整(変動金額)
  NEW.variable_amount = ROUND(NEW.variable_amount, 2);


  -- 導出属性の算出(締日付/入金期限日付)
  -- 両項目の設定がいずれも設定がない場合に算出される。(片方だけ設定がある場合はNULL制約エラー)
  IF NEW.cut_off_date IS NULL AND NEW.deposit_limit_date IS NULL THEN
    rec = inventories.calc_deposit_deadline(NEW.costomer_id, NEW.business_date);
    NEW.cut_off_date = rec.cut_off_date;
    NEW.deposit_limit_date = rec.deposit_date;
  END IF;

  -- 導出属性の算出(請求番号)
  NEW.billing_id = inventories.upsert_bills_for_cutoff_date(
    NEW.costomer_id,
    NEW.cut_off_date,
    NEW.deposit_limit_date,
    NEW.variable_amount,
    NEW.created_by
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT
  ON inventories.correct_receivable_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.correct_receivable_instructions_pre_process();


-- 売掛金修正指示:登録「後」処理
--  別テーブル登録(売掛変動履歴)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.correct_receivable_instructions_post_process() RETURNS TRIGGER AS $$
BEGIN

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  1.売掛変動履歴 INFO:
  INSERT INTO inventories.receivable_histories
  VALUES (
    default,
    NEW.business_date,
    NEW.operation_timestamp,
    NEW.costomer_id,
    NEW.variable_amount,
    'OTHER',
    NEW.receivable_correct_instruction_no,
    NEW.billing_id,
    default,
    default,
    default,
    NEW.created_by,
    NEW.created_by
  );

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  AFTER INSERT
  ON inventories.correct_receivable_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.correct_receivable_instructions_post_process();
