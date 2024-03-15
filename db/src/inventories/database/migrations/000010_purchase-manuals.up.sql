-- シーケンス
DROP SEQUENCE IF EXISTS inventories.payment_no_seed;
CREATE SEQUENCE inventories.payment_no_seed START 1;

DROP SEQUENCE IF EXISTS inventories.ordering_no_seed;
CREATE SEQUENCE inventories.ordering_no_seed START 1;

DROP SEQUENCE IF EXISTS inventories.warehousing_no_seed;
CREATE SEQUENCE inventories.warehousing_no_seed START 1;


-- 支払:登録「前」処理
--  導出属性の算出:登録時のみ(支払ID)
--  導出属性の算出(変更凍結日時)
--  有効桁数調整(支払金額)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.payments_pre_process() RETURNS TRIGGER AS $$
BEGIN
  -- 導出属性の算出:登録時のみ(支払ID)
  IF (TG_OP = 'INSERT') THEN
    NEW.payment_id:='PM-'||to_char(nextval('inventories.payment_no_seed'),'FM0000000');
  END IF;

  -- 導出属性の算出(変更凍結日時)
  IF (NEW.freeze_changed_timestamp IS NULL AND (NEW.payment_status = 'CONFIRMED' OR NEW.payment_status = 'COMPLETED')) THEN
    NEW.freeze_changed_timestamp:=current_timestamp;
  END IF;

  -- 有効桁数調整(支払金額)
  NEW.payment_amount = ROUND(NEW.payment_amount, 2);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.payments
  FOR EACH ROW
EXECUTE PROCEDURE inventories.payments_pre_process();


-- 支払登録/金額更新
-- Create Function
CREATE OR REPLACE FUNCTION inventories.upsert_payments_for_cutoff_date(
  i_supplier_id text,
  i_cut_off_date date,
  i_payment_limit_date date,
  i_variable_amount numeric,
  i_create_by text
) RETURNS text AS $$
DECLARE
  rec RECORD;
  r_payment_id text;
BEGIN
  SELECT * INTO rec FROM inventories.payments
    WHERE  supplier_id = i_supplier_id AND cut_off_date = i_cut_off_date AND payment_limit_date = i_payment_limit_date
    FOR UPDATE;

  IF rec IS NULL THEN
    INSERT INTO inventories.payments VALUES (
      default,
      i_supplier_id,
      i_cut_off_date,
      i_payment_limit_date,
      i_variable_amount,
      default,
      NULL,
      NULL,
      NULL,
      default,
      default,
      i_create_by,
      i_create_by
    ) RETURNING payment_id INTO r_payment_id;
    RETURN r_payment_id;

  ELSE
    UPDATE inventories.payments
    SET payment_amount = rec.payment_amount + i_variable_amount,
        updated_by = i_create_by
    WHERE  supplier_id = i_supplier_id AND cut_off_date = i_cut_off_date AND payment_limit_date = i_payment_limit_date;
    RETURN rec.payment_id;
  END IF;

END;
$$ LANGUAGE plpgsql;


-- 支払:チェック制約
--  属性相関チェック制約(締日付/支払期限日付)

-- Create Constraint
ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS payment_limit_date_check;
ALTER TABLE inventories.payments ADD CONSTRAINT payment_limit_date_check CHECK (
  cut_off_date < payment_limit_date
);

-- 支払:チェック制約
--  属性相関チェック制約(締日付/金額確定日付)

-- Create Constraint
ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS amount_confirmed_date_check;
ALTER TABLE inventories.payments ADD CONSTRAINT amount_confirmed_date_check CHECK (
  cut_off_date < amount_confirmed_date
);

-- 支払:チェック制約
--  属性相関チェック制約(締日付/金額確定日付)

-- Create Constraint
ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS payment_date_check;
ALTER TABLE inventories.payments ADD CONSTRAINT payment_date_check CHECK (
  cut_off_date < payment_date AND amount_confirmed_date <= payment_date
);


-- 月次買掛金サマリ:登録「前」処理
--  導出属性の算出(残高)
--  有効桁数調整(月初残高/購入金額/支払金額/その他金額)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.month_payables_pre_process() RETURNS TRIGGER AS $$
BEGIN
  --  有効桁数調整(月初残高/購入金額/支払金額/その他金額)
  NEW.init_balance = ROUND(NEW.init_balance, 2);
  NEW.purchase_amount = ROUND(NEW.purchase_amount, 2);
  NEW.payment_amount = ROUND(NEW.payment_amount, 2);
  NEW.other_amount = ROUND(NEW.other_amount, 2);
  -- 導出属性の算出(在庫数量)
  NEW.present_balance = NEW.init_balance + NEW.purchase_amount - NEW.payment_amount + NEW.other_amount;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.month_accounts_payables
  FOR EACH ROW
EXECUTE PROCEDURE inventories.month_payables_pre_process();


-- 現在買掛金サマリ:登録「前」処理
--  有効桁数調整(残高)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.current_payables_pre_process() RETURNS TRIGGER AS $$
BEGIN
  --  有効桁数調整(残高)
  NEW.present_balance = ROUND(NEW.present_balance, 2);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.current_accounts_payables
  FOR EACH ROW
EXECUTE PROCEDURE inventories.current_payables_pre_process();


-- 買掛変動履歴:チェック制約
--  属性相関チェック制約(買掛変動種類/変動金額)

-- Create Constraint
ALTER TABLE inventories.payable_histories DROP CONSTRAINT IF EXISTS payable_histories_payable_type_check;
ALTER TABLE inventories.payable_histories ADD CONSTRAINT payable_histories_payable_type_check CHECK (
  CASE
    -- 買掛変動種類が「仕入購入」の場合、変動金額が0より大きい値であること
    WHEN payable_type = 'PURCHASE' AND variable_amount <= 0.00 THEN FALSE
    -- 買掛変動種類が「仕入返品」「支払」の場合、変動金額が0より小さい値であること
    WHEN payable_type = 'ORDER_RETURN' AND variable_amount >= 0.00 THEN FALSE
    WHEN payable_type = 'PAYMENT' AND variable_amount >= 0.00 THEN FALSE
    ELSE TRUE
  END
);


-- 買掛変動履歴:登録「前」処理
--  有効桁数調整(変動金額)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.payable_histories_pre_process() RETURNS TRIGGER AS $$
BEGIN
  --  有効桁数調整(変動金額)
  NEW.variable_amount = ROUND(NEW.variable_amount, 2);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.payable_histories
  FOR EACH ROW
EXECUTE PROCEDURE inventories.payable_histories_pre_process();


-- 買掛変動履歴:登録「後」処理
--  別テーブル登録/更新(月次買掛金サマリ/現在買掛金サマリ)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.upsert_accounts_payables() RETURNS TRIGGER AS $$
DECLARE
  yyyymm text:=to_char(NEW.business_date, 'YYYYMM');

  t_init_balance numeric;
  t_purchase_amount numeric;
  t_payment_amount numeric;
  t_other_amount numeric;

  recent_rec RECORD; --検索結果レコード(現在年月)
  last_rec RECORD;--検索結果レコード(過去最新年月)
  rec RECORD;
BEGIN
--  1.月次買掛金サマリ INFO:

  -- 1.1.現在年月データの取得
  SELECT * INTO recent_rec
    FROM inventories.month_accounts_payables
    WHERE supplier_id = NEW.supplier_id AND year_month = yyyymm
    FOR UPDATE;

  -- 1.2.月初残高/購入金額/支払金額/その他金額の算出
  IF recent_rec IS NULL THEN
    -- 現在年月データが存在しないケース
    -- 過去最新残高の取得
    SELECT * INTO last_rec
      FROM inventories.month_accounts_payables
      WHERE supplier_id = NEW.supplier_id AND year_month < yyyymm
      ORDER BY year_month DESC
      LIMIT 1;
    -- 過去最新在庫数が取得できた場合は月初残高に設定
    t_init_balance:=CASE WHEN last_rec IS NULL THEN 0.00 ELSE last_rec.present_balance END;
    t_purchase_amount:=0.00;
    t_payment_amount:=0.00;
    t_other_amount:=0.00;
  ELSE
    -- 現在年月データが存在するケース
    t_init_balance:=recent_rec.init_balance;
    t_purchase_amount:=recent_rec.purchase_amount;
    t_payment_amount:=recent_rec.payment_amount;
    t_other_amount:=recent_rec.other_amount;
  END IF;

  -- 1.3.取引数量の計上(買掛変動種類により判断)
  IF NEW.payable_type='PURCHASE' OR NEW.payable_type='ORDER_RETURN' THEN
    t_purchase_amount:=t_purchase_amount + NEW.variable_amount;
  ELSIF NEW.payable_type='PAYMENT' THEN
    t_payment_amount:=t_payment_amount - NEW.variable_amount;
  ELSIF NEW.payable_type='OTHER' THEN
    t_other_amount:=t_other_amount + NEW.variable_amount;
  END IF;

  -- 1.4.登録/更新
  IF recent_rec IS NULL THEN
    -- 現在年月データが存在しないケース
    INSERT INTO inventories.month_accounts_payables VALUES (
      NEW.supplier_id,
      yyyymm,
      t_init_balance,
      t_purchase_amount,
      t_payment_amount,
      t_other_amount,
      default,
      default,
      default,
      NEW.created_by,
      NEW.created_by
    );
  ELSE
    -- 現在年月データが存在するケース
    UPDATE inventories.month_accounts_payables
    SET purchase_amount = t_purchase_amount,
        payment_amount = t_payment_amount,
        other_amount = t_other_amount
    WHERE supplier_id = NEW.supplier_id AND year_month = yyyymm;
  END IF;

  -- 1.5.現在年月以降のデータ更新(存在する場合)
  FOR rec IN SELECT * FROM inventories.month_accounts_payables
    WHERE supplier_id = NEW.supplier_id AND year_month > yyyymm LOOP

    UPDATE inventories.month_accounts_payables
    SET init_balance = rec.init_balance + NEW.variable_amount
    WHERE supplier_id = NEW.supplier_id AND year_month = rec.year_month;
  END LOOP;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

--  2.現在買掛金サマリ INFO:

  -- 2.1.最新データの取得
  SELECT * INTO recent_rec
    FROM inventories.current_accounts_payables
    WHERE supplier_id = NEW.supplier_id
    FOR UPDATE;

  -- 2.2.登録/更新
  IF recent_rec IS NULL THEN
    -- 最新データが存在しないケース
    INSERT INTO inventories.current_accounts_payables VALUES (
      NEW.supplier_id,
      NEW.variable_amount,
      default,
      default,
      NEW.created_by,
      NEW.created_by
    );
  ELSE
    -- 最新データが存在するケース
    UPDATE inventories.current_accounts_payables
    SET present_balance = recent_rec.present_balance + NEW.variable_amount
    WHERE supplier_id = NEW.supplier_id;
  END IF;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  AFTER INSERT
  ON inventories.payable_histories
  FOR EACH ROW
EXECUTE PROCEDURE inventories.upsert_accounts_payables();


-- 発注仕入先取得
-- Create Function
CREATE OR REPLACE FUNCTION inventories.supplier_id_for_orderings(i_ordering_id text) RETURNS text AS $$
BEGIN
  RETURN(SELECT supplier_id FROM inventories.orderings WHERE ordering_id = i_ordering_id);
END;
$$ LANGUAGE plpgsql;


-- 発注:登録「前」処理
--  導出属性の算出:登録時のみ(発注ID)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.orderings_pre_process() RETURNS TRIGGER AS $$
BEGIN
  -- 導出属性の算出:登録時のみ(支払ID)
  IF (TG_OP = 'INSERT') THEN
    NEW.ordering_id:='PO-'||to_char(nextval('inventories.ordering_no_seed'),'FM0000000');
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.orderings
  FOR EACH ROW
EXECUTE PROCEDURE inventories.orderings_pre_process();


-- 発注時単価取得
-- Create Function
CREATE OR REPLACE FUNCTION inventories.cost_price_for_orders(i_ordering_id text, i_product_id text) RETURNS numeric AS $$
BEGIN
  RETURN(SELECT unit_price FROM inventories.ordering_details WHERE ordering_id = i_ordering_id AND product_id = i_product_id);
END;
$$ LANGUAGE plpgsql;


-- 発注明細:チェック制約
--  属性相関チェック制約(発注番号/商品ID)

-- Create Constraint
ALTER TABLE inventories.ordering_details DROP CONSTRAINT IF EXISTS ordering_details_supplier_id_check;
ALTER TABLE inventories.ordering_details ADD CONSTRAINT ordering_details_supplier_id_check CHECK (
  inventories.supplier_id_for_orderings(ordering_id) = inventories.supplier_id_for_products(product_id)
);


-- 発注明細:チェック制約
--  属性相関チェック制約(発注番号/予定納期日付)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.is_after_arrival_date(i_ordering_id text, arrival_date date) RETURNS boolean AS $$
BEGIN
  -- 発注日付よりも納期日付が後である場合にTrue
  RETURN(SELECT order_date < arrival_date FROM inventories.orderings WHERE ordering_id = i_ordering_id);
END;
$$ LANGUAGE plpgsql;

-- Create Constraint
ALTER TABLE inventories.ordering_details DROP CONSTRAINT IF EXISTS ordering_details_estimate_arrival_date_check;
ALTER TABLE inventories.ordering_details ADD CONSTRAINT ordering_details_estimate_arrival_date_check CHECK (
  inventories.is_after_arrival_date(ordering_id, estimate_arrival_date)
);


-- 発注明細:登録「前」処理
--  登録時初期化(入庫数量/キャンセル数量)
--  導出属性の算出:登録時のみ(単価/想定利益率/標準納期日付/予定納期日付)
--  導出属性の算出(残数量)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.ordering_details_pre_process() RETURNS TRIGGER AS $$
DECLARE
  t_order_date date;
  t_days_to_arrive integer;
BEGIN
  IF (TG_OP = 'INSERT') THEN
    --  登録時初期化(入庫数量/キャンセル数量)
    NEW.warehousing_quantity:=0;
    NEW.cancel_quantity:=0;

--  導出属性の算出:登録時のみ(単価)
    IF NEW.unit_price IS NULL THEN
      NEW.unit_price = inventories.cost_price_for_products(NEW.product_id);
    ELSE
      NEW.unit_price = ROUND(NEW.unit_price, 2);
    END IF;

--  導出属性の算出:登録時のみ(想定利益率)
    NEW.estimate_profit_rate = inventories.calc_profit_rate_by_cost_price(NEW.product_id, NEW.unit_price);

--  導出属性の算出:登録時のみ(標準納期日付/予定納期日付)
    -- 発注日の取得
    SELECT order_date INTO t_order_date FROM inventories.orderings WHERE ordering_id = NEW.ordering_id;
    -- 標準入荷日数の取得
    t_days_to_arrive = inventories.calc_days_to_arriva(NEW.product_id);
    NEW.standard_arrival_date = DATE(t_order_date + CAST((t_days_to_arrive) || ' Day' AS interval));
    NEW.estimate_arrival_date = NEW.standard_arrival_date;

  END IF;

  --  導出属性の算出(残数量)
  NEW.remaining_quantity:=NEW.ordering_quantity - NEW.warehousing_quantity - NEW.cancel_quantity;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.ordering_details
  FOR EACH ROW
EXECUTE PROCEDURE inventories.ordering_details_pre_process();


-- 入荷仕入先取得
-- Create Function
CREATE OR REPLACE FUNCTION inventories.supplier_id_for_warehousings(i_warehousing_id text) RETURNS text AS $$
BEGIN
  RETURN(SELECT supplier_id FROM inventories.warehousings WHERE warehousing_id = i_warehousing_id);
END;
$$ LANGUAGE plpgsql;


-- 入荷:チェック制約
--  テーブル相関チェック制約(支払(締日付/支払期限日付)の金額未確定チェック)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.is_before_freeze_paymant_amounts(i_supplier_id text, i_cut_off_date date, i_payment_limit_date date, operation_timestamp timestamp) RETURNS boolean AS $$
BEGIN
  -- 支払金額確定日時よりも処理日時が前である場合にTrue
  RETURN(SELECT freeze_changed_timestamp > operation_timestamp FROM inventories.payments
    WHERE  supplier_id = i_supplier_id AND cut_off_date = i_cut_off_date AND payment_limit_date = i_payment_limit_date);
END;
$$ LANGUAGE plpgsql;

-- Create Constraint
ALTER TABLE inventories.warehousings DROP CONSTRAINT IF EXISTS warehousings_payment_id_check;
ALTER TABLE inventories.warehousings ADD CONSTRAINT warehousings_payment_id_check CHECK (
  inventories.is_before_freeze_paymant_amounts(supplier_id, cut_off_date,payment_limit_date, operation_timestamp)
);


-- 入荷:登録「前」処理
--  導出属性の算出:登録時のみ(入荷ID/締日付/支払期限日付/支払番号)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.warehousings_pre_process() RETURNS TRIGGER AS $$
DECLARE
  rec RECORD;
BEGIN
  IF (TG_OP = 'INSERT') THEN
    -- 導出属性の算出:登録時のみ(入荷ID)
    NEW.warehousing_id:='WH-'||to_char(nextval('inventories.warehousing_no_seed'),'FM0000000');

    -- 導出属性の算出:登録時のみ(締日付/支払期限日付)
    -- 両項目の設定がいずれも設定がない場合に算出される。(片方だけ設定がある場合はNULL制約エラー)
    IF NEW.cut_off_date IS NULL AND NEW.payment_limit_date IS NULL THEN
      rec = inventories.calc_payment_deadline(NEW.supplier_id, NEW.warehouse_date);
      NEW.cut_off_date = rec.cut_off_date;
      NEW.payment_limit_date = rec.payment_date;
    END IF;

    -- 導出属性の算出:登録時のみ(支払番号)
    NEW.payment_id = inventories.upsert_payments_for_cutoff_date(NEW.supplier_id, NEW.cut_off_date, NEW.payment_limit_date, 0, NEW.created_by);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.warehousings
  FOR EACH ROW
EXECUTE PROCEDURE inventories.warehousings_pre_process();


-- 入荷時単価取得
-- Create Function
CREATE OR REPLACE FUNCTION inventories.cost_price_for_warehouse(i_warehousing_id text, i_ordering_id text, i_product_id text) RETURNS numeric AS $$
BEGIN
  RETURN(SELECT unit_price FROM inventories.warehousing_details WHERE warehousing_id = i_warehousing_id AND ordering_id = i_ordering_id AND product_id = i_product_id);
END;
$$ LANGUAGE plpgsql;


-- 入荷明細:チェック制約
--  属性相関チェック制約(入荷数量/返品数量)

-- Create Constraint
ALTER TABLE inventories.warehousing_details DROP CONSTRAINT IF EXISTS warehousing_details_return_quantity_check;
ALTER TABLE inventories.warehousing_details ADD CONSTRAINT warehousing_details_return_quantity_check CHECK (
  return_quantity <= warehousing_quantity
);


-- 入荷明細:登録「前」処理
--  登録時初期化(返品数量)
--  導出属性の算出:登録時のみ(単価/想定利益率)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.warehousing_details_pre_process() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    --  登録時初期化(返品数量)
    NEW.return_quantity:=0;

--  導出属性の算出:登録時のみ(単価)
    IF NEW.unit_price IS NULL THEN
      NEW.unit_price = inventories.cost_price_for_orders(NEW.ordering_id, NEW.product_id);
    ELSE
      NEW.unit_price = ROUND(NEW.unit_price, 2);
    END IF;

--  導出属性の算出:登録時のみ(想定利益率)
    NEW.estimate_profit_rate = inventories.calc_profit_rate_by_cost_price(NEW.product_id, NEW.unit_price);

  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.warehousing_details
  FOR EACH ROW
EXECUTE PROCEDURE inventories.warehousing_details_pre_process();


-- 入荷明細:登録「後」処理
--  別テーブル登録/更新(発注明細/支払/買掛変動履歴/在庫変動履歴)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.warehousing_post_process() RETURNS TRIGGER AS $$
DECLARE
  rec RECORD;
BEGIN

  SELECT * INTO rec FROM inventories.warehousings WHERE warehousing_id = NEW.warehousing_id;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  1.発注明細 INFO:
  UPDATE inventories.ordering_details
  SET warehousing_quantity = warehousing_quantity + NEW.warehousing_quantity,
      updated_by = NEW.created_by
  WHERE ordering_id = NEW.ordering_id AND product_id = NEW.product_id;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  2.支払 INFO:
  UPDATE inventories.payments
  SET payment_amount = payment_amount + NEW.warehousing_quantity * NEW.unit_price,
      updated_by = NEW.created_by
  WHERE payment_id = rec.payment_id;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  3.買掛変動履歴 INFO:
  INSERT INTO inventories.payable_histories
  VALUES (
    default,
    rec.warehouse_date,
    rec.operation_timestamp,
    rec.supplier_id,
    NEW.warehousing_quantity * NEW.unit_price,
    'PURCHASE',
    NEW.warehousing_detail_no,
    rec.payment_id,
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
    rec.warehouse_date,
    rec.operation_timestamp,
    NEW.product_id,
    NEW.site_id,
    NEW.warehousing_quantity,
    NEW.warehousing_quantity * NEW.unit_price,
    'PURCHASE',
    NEW.warehousing_detail_no,
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
  ON inventories.warehousing_details
  FOR EACH ROW
EXECUTE PROCEDURE inventories.warehousing_post_process();


-- 発注キャンセル指示:登録「後」処理
--  別テーブル変更(発注明細)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.update_order_cancel_quantity() RETURNS TRIGGER AS $$
BEGIN
  UPDATE inventories.ordering_details
  SET cancel_quantity = cancel_quantity + NEW.quantity,
      updated_by = NEW.created_by
  WHERE ordering_id = NEW.ordering_id AND product_id = NEW.product_id;

  return NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  BEFORE INSERT
  ON inventories.order_cancel_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.update_order_cancel_quantity();


-- 発注納期変更指示:登録「後」処理
--  別テーブル変更(発注明細)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.update_order_estimate_arrive_date() RETURNS TRIGGER AS $$
BEGIN
  UPDATE inventories.ordering_details
  SET estimate_arrival_date = NEW.changed_arrival_date,
      updated_by = NEW.created_by
  WHERE ordering_id = NEW.ordering_id AND product_id = NEW.product_id;

  return NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  BEFORE INSERT
  ON inventories.order_arrival_change_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.update_order_estimate_arrive_date();


-- 支払金額確定指示:登録「後」処理
--  別テーブル変更(支払)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.update_payment_comfirm_date() RETURNS TRIGGER AS $$
BEGIN
  UPDATE inventories.payments
  SET payment_status = 'CONFIRMED',
      amount_confirmed_date = NEW.business_date,
      updated_by = NEW.created_by
  WHERE payment_id = NEW.payment_id;

  return NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  BEFORE INSERT
  ON inventories.payment_confirm_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.update_payment_comfirm_date();


-- 支払指示:登録「後」処理
--  別テーブル登録/変更(買掛変動履歴/支払)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.execute_payment() RETURNS TRIGGER AS $$
DECLARE
  rec RECORD;
BEGIN

  SELECT * INTO rec FROM inventories.payments WHERE payment_id = NEW.payment_id;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  1.支払 INFO:
  UPDATE inventories.payments
  SET payment_status = 'COMPLETED',
      payment_date = NEW.business_date,
      updated_by = NEW.created_by
  WHERE payment_id = NEW.payment_id;

  --  2.買掛変動履歴 INFO:
  INSERT INTO inventories.payable_histories
  VALUES (
    default,
    NEW.business_date,
    NEW.operation_timestamp,
    rec.supplier_id,
    - rec.payment_amount,
    'PAYMENT',
    NEW.payment_instruction_no,
    NEW.payment_id,
    default,
    default,
    NEW.created_by,
    NEW.created_by
  );

  return NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  BEFORE INSERT
  ON inventories.payment_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.execute_payment();


-- 入荷返品指示:登録「前」処理
--  導出属性の算出(単価/締日付/支払期限日付/支払番号)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.warehousing_return_instructions_pre_process() RETURNS TRIGGER AS $$
DECLARE
  i_supplier_id text;
  rec RECORD;
BEGIN

  --  導出属性の算出(単価)
  IF NEW.unit_price IS NULL THEN
    NEW.unit_price = inventories.cost_price_for_warehouse(NEW.warehousing_id, NEW.ordering_id, NEW.product_id);
  ELSE
    NEW.unit_price = ROUND(NEW.unit_price, 2);
  END IF;

  -- 導出属性の算出(締日付/支払期限日付)
  -- 両項目の設定がいずれも設定がない場合に算出される。(片方だけ設定がある場合はNULL制約エラー)
  IF NEW.cut_off_date IS NULL AND NEW.payment_limit_date IS NULL THEN
    SELECT supplier_id INTO i_supplier_id FROM inventories.warehousings WHERE warehousing_id = NEW.warehousing_id;

    rec = inventories.calc_payment_deadline(i_supplier_id, NEW.business_date);
    NEW.cut_off_date = rec.cut_off_date;
    NEW.payment_limit_date = rec.payment_date;
  END IF;

  -- 導出属性の算出(支払番号)
  NEW.payment_id = inventories.upsert_payments_for_cutoff_date(
    i_supplier_id,
    NEW.cut_off_date,
    NEW.payment_limit_date,
    - NEW.quantity * NEW.unit_price,
    NEW.created_by
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT
  ON inventories.warehousing_return_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.warehousing_return_instructions_pre_process();


-- 入荷返品指示:登録「後」処理
--  別テーブル登録(買掛変動履歴/在庫変動履歴)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.warehousing_return_instructions_post_process() RETURNS TRIGGER AS $$
DECLARE
  i_supplier_id text;
BEGIN

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  1.買掛変動履歴 INFO:
  SELECT supplier_id INTO i_supplier_id FROM inventories.warehousings WHERE warehousing_id = NEW.warehousing_id;
  INSERT INTO inventories.payable_histories
  VALUES (
    default,
    NEW.business_date,
    NEW.operation_timestamp,
    i_supplier_id,
    - NEW.quantity * NEW.unit_price,
    'ORDER_RETURN',
    NEW.return_instruction_no,
    NEW.payment_id,
    default,
    default,
    NEW.created_by,
    NEW.created_by
  );

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  2.在庫変動履歴 INFO:
  -- INSERT INTO inventories.inventory_histories
  -- VALUES (
  --   default,
  --   NEW.business_date,
  --   NEW.operation_timestamp,
  --   NEW.product_id,
  --   NEW.site_id,FIXME:
  --   - NEW.quantity,
  --   - NEW.quantity * NEW.unit_price,
  --   'ORDER_RETURN',
  --   NEW.return_instruction_no,
  --   default,
  --   default,
  --   NEW.created_by,
  --   NEW.created_by
  -- );

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  AFTER INSERT
  ON inventories.warehousing_return_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.warehousing_return_instructions_post_process();


-- 買掛金修正指示:登録「前」処理
--  有効桁数調整(変動金額)
--  導出属性の算出(締日付/支払期限日付/支払番号)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.correct_payable_instructions_pre_process() RETURNS TRIGGER AS $$
DECLARE
  rec RECORD;
BEGIN

  --  有効桁数調整(変動金額)
  NEW.variable_amount = ROUND(NEW.variable_amount, 2);


  -- 導出属性の算出(締日付/支払期限日付)
  -- 両項目の設定がいずれも設定がない場合に算出される。(片方だけ設定がある場合はNULL制約エラー)
  IF NEW.cut_off_date IS NULL AND NEW.payment_limit_date IS NULL THEN
    rec = inventories.calc_payment_deadline(NEW.supplier_id, NEW.business_date);
    NEW.cut_off_date = rec.cut_off_date;
    NEW.payment_limit_date = rec.payment_date;
  END IF;

  -- 導出属性の算出(支払番号)
  NEW.payment_id = inventories.upsert_payments_for_cutoff_date(
    NEW.supplier_id,
    NEW.cut_off_date,
    NEW.payment_limit_date,
    NEW.variable_amount,
    NEW.created_by
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT
  ON inventories.correct_payable_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.correct_payable_instructions_pre_process();

-- 買掛金修正指示:登録「後」処理
--  別テーブル登録(買掛変動履歴)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.correct_payable_instructions_post_process() RETURNS TRIGGER AS $$
BEGIN

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  --  1.買掛変動履歴 INFO:
  INSERT INTO inventories.payable_histories
  VALUES (
    default,
    NEW.business_date,
    NEW.operation_timestamp,
    NEW.supplier_id,
    NEW.variable_amount,
    'OTHER',
    NEW.payable_correct_instruction_no,
    NEW.payment_id,
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
  ON inventories.correct_payable_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.correct_payable_instructions_post_process();
