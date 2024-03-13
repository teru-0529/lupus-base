-- 想定利益率計算(by原価指定)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.calc_profit_rate(i_selling_price numeric, i_cost_price numeric) RETURNS numeric AS $$
BEGIN
  RETURN ROUND((i_selling_price - i_cost_price) / i_selling_price, 2);
END;
$$ LANGUAGE plpgsql;


-- 商品:登録「前」処理
--  導出属性の算出(標準利益率)
--  有効桁数調整(売価/原価)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.products_pre_process() RETURNS TRIGGER AS $$
BEGIN
  -- 有効桁数調整(売価/原価)
  NEW.selling_price = ROUND(NEW.selling_price, 2);
  NEW.cost_price = ROUND(NEW.cost_price, 2);
  -- 導出属性の算出(標準利益率)
  IF (NEW.selling_price = 0) THEN
    NEW.standard_profit_rate = 0.00;
  ELSE
    NEW.standard_profit_rate = inventories.calc_profit_rate(NEW.selling_price, NEW.cost_price);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.products
  FOR EACH ROW
EXECUTE PROCEDURE inventories.products_pre_process();


-- 仕入先:チェック制約
--  属性相関チェック制約(発注方針/発注曜日)

-- Create Constraint
ALTER TABLE inventories.suppliers DROP CONSTRAINT IF EXISTS suppliers_order_policy_check;
ALTER TABLE inventories.suppliers ADD CONSTRAINT suppliers_order_policy_check CHECK (
  -- 発注方法が「定期発注」の場合、発注曜日が「必須」
  -- 発注方法が「随時発注」の場合、発注曜日が存在してはいけない
  CASE
    WHEN order_policy='PERIODICALLY' AND order_week_num IS NULL THEN FALSE
    WHEN order_policy='AS_NEEDED' AND order_week_num IS NOT NULL THEN FALSE
    ELSE TRUE
  END
);

-- 得意先/仕入先:チェック制約
--  テーブル相関チェック制約(取引状況:取引銀行が存在すること)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.exist_dealing_bank(i_company_id text) RETURNS boolean AS $$
BEGIN
  -- 取引銀行のPK検索し存在する場合にTrue
  RETURN(SELECT COUNT(1) > 0 FROM inventories.dealing_banks WHERE company_id = i_company_id);
END;
$$ LANGUAGE plpgsql;

-- Create Constraint
ALTER TABLE inventories.costomers DROP CONSTRAINT IF EXISTS costomers_exist_bank_check;
ALTER TABLE inventories.costomers ADD CONSTRAINT costomers_exist_bank_check CHECK (
  -- 取引状況が「取引中」の場合、取引銀行が存在すること
  CASE
    WHEN dealing_status = 'ACTIVE' AND NOT inventories.exist_dealing_bank(costomer_id) THEN FALSE
    ELSE TRUE
  END
);

-- Create Constraint
ALTER TABLE inventories.suppliers DROP CONSTRAINT IF EXISTS suppliers_exist_bank_check;
ALTER TABLE inventories.suppliers ADD CONSTRAINT suppliers_exist_bank_check CHECK (
  -- 取引状況が「取引中」の場合、取引銀行が存在すること
  CASE
    WHEN dealing_status = 'ACTIVE' AND NOT inventories.exist_dealing_bank(supplier_id) THEN FALSE
    ELSE TRUE
  END
);

-- ビューテーブル(送付先)
--  企業・企業送付先を統合

-- Create View
CREATE OR REPLACE VIEW inventories.view_company_destinations AS
  SELECT
    company_id,
    0 AS seq_no,
    postal_code,
    address,
    phone_no,
    fax_no
  FROM inventories.companies
  UNION
  SELECT
    costomer_id AS company_id,
    ROW_NUMBER() OVER(PARTITION BY 'company_id' ORDER BY 'destination_no') AS seq_no,
    postal_code,
    address,
    phone_no,
    fax_no
  FROM inventories.company_destinations
  ORDER BY company_id, seq_no;


-- 商品得意先取得
-- Create Function
CREATE OR REPLACE FUNCTION inventories.supplier_id_for_products(i_product_id text) RETURNS text AS $$
BEGIN
  RETURN(SELECT supplier_id FROM inventories.products WHERE product_id = i_product_id);
END;
$$ LANGUAGE plpgsql;


-- 商品原価取得
-- Create Function
CREATE OR REPLACE FUNCTION inventories.cost_price_for_products(i_product_id text) RETURNS numeric AS $$
BEGIN
  RETURN(SELECT cost_price FROM inventories.products WHERE product_id = i_product_id);
END;
$$ LANGUAGE plpgsql;


-- 想定利益率計算(by原価指定)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.calc_profit_rate_by_cost_price(i_product_id text, i_cost_price numeric) RETURNS numeric AS $$
DECLARE
  i_selling_price numeric;
BEGIN
  SELECT selling_price INTO i_selling_price FROM inventories.products WHERE product_id = i_product_id;
  IF i_selling_price IS NULL OR i_selling_price = 0 OR i_selling_price < i_cost_price THEN
    RETURN 0.00;
  ELSE
    RETURN inventories.calc_profit_rate(i_selling_price, i_cost_price);
  END IF;
END;
$$ LANGUAGE plpgsql;


-- 想定利益率計算(by売価指定)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.calc_profit_rate_by_selling_price(i_product_id text, i_selling_price numeric) RETURNS numeric AS $$
DECLARE
  i_cost_price numeric;
BEGIN
  SELECT cost_price INTO i_cost_price FROM inventories.products WHERE product_id = i_product_id;
  IF i_cost_price IS NULL OR i_selling_price < i_cost_price THEN
    RETURN 0.00;
  ELSE
    RETURN inventories.calc_profit_rate(i_selling_price, i_cost_price);
  END IF;
END;
$$ LANGUAGE plpgsql;


-- 標準納期日数計算(商品に指定のない場合は仕入れ先の値)
-- Create Function
CREATE OR REPLACE FUNCTION inventories.calc_days_to_arrival(i_product_id text) RETURNS integer AS $$
DECLARE
  rec RECORD;
  i_days_to_arrive integer;
BEGIN
  SELECT * INTO rec FROM inventories.products WHERE product_id = i_product_id;
  IF rec IS NULL THEN
    RETURN NULL;
  ELSIF rec.days_to_arrive IS NULL THEN
    RETURN(SELECT days_to_arrive FROM inventories.suppliers WHERE supplier_id = rec.supplier_id);
  ELSE
    RETURN rec.days_to_arrive;
  END IF;
END;
$$ LANGUAGE plpgsql;


-- 締日付、支払期限日付の計算INFO:
-- Create Function
CREATE OR REPLACE FUNCTION inventories.calc_payment_deadline(
  i_supplier_id text,
  operation_date date,
  OUT cut_off_date date,
  OUT payment_date date
  ) AS $$
DECLARE
  rec record;
  cutoff_day_interval interval;
  payment_day_interval interval;
  month_interval interval;
  first_date date;
  last_date date;
BEGIN
  -- 1.仕入先検索
  SELECT * INTO rec FROM inventories.suppliers WHERE supplier_id = i_supplier_id;
  cutoff_day_interval = CAST((rec.cut_off_day - 1) || ' Day' AS interval);
  payment_day_interval = CAST((rec.payment_day - 1) || ' Day' AS interval);
  month_interval = CAST(rec.month_of_payment_term || ' month' AS interval);

  -- 2.当月月初日付/月末日付算出(DATE_TRUNCで日付を切り捨てた後、翌月の1日前)
  first_date = DATE(DATE_TRUNC('month', operation_date));
  last_date = DATE(first_date + interval '1 month' - interval '1 Day');

  -- -- 3.締日付算出
  IF rec.cut_off_day < EXTRACT(day FROM operation_date) THEN
    -- 処理日が締日を過ぎている場合・・・翌月締め
    cut_off_date = DATE(first_date + interval '1 month' + cutoff_day_interval);
  ELSIF EXTRACT(day FROM last_date) < rec.cut_off_day THEN
    -- 締日が当月末日よりも後(=締日99指定)の場合・・・当月末締め
    cut_off_date = last_date;
  ELSE
    -- 処理日が締日未到来の場合・・・当月締め
    cut_off_date = DATE(first_date + cutoff_day_interval);
  END IF;

  -- 4.支払月月初日付/月末日付算出
  first_date = DATE(DATE_TRUNC('month', cut_off_date) + month_interval);
  last_date = DATE(first_date + interval '1 month' - interval '1 Day');

  -- 5.支払期限日付算出
  IF EXTRACT(day FROM last_date) < rec.payment_day THEN
    -- 支払期限日が支払月末日よりも後(=支払期限日99指定)の場合・・・月末支払
    payment_date = last_date;
  ELSE
    payment_date = DATE(first_date + payment_day_interval);
  END IF;

END;
$$ LANGUAGE plpgsql;


-- 締日付、入金期限日付の計算INFO:
-- Create Function
CREATE OR REPLACE FUNCTION inventories.calc_deposit_deadline(
  i_costomer_id text,
  operation_date date,
  OUT cut_off_date date,
  OUT deposit_date date
  ) AS $$
DECLARE
  rec record;
  cutoff_day_interval interval;
  deposit_day_interval interval;
  month_interval interval;
  first_date date;
  last_date date;
BEGIN
  -- 1.仕入先検索
  SELECT * INTO rec FROM inventories.costomers WHERE costomer_id = i_costomer_id;
  cutoff_day_interval = CAST((rec.cut_off_day - 1) || ' Day' AS interval);
  deposit_day_interval = CAST((rec.deposit_day - 1) || ' Day' AS interval);
  month_interval = CAST(rec.month_of_deposit_term || ' month' AS interval);

  -- 2.当月月初日付/月末日付算出(DATE_TRUNCで日付を切り捨てた後、翌月の1日前)
  first_date = DATE(DATE_TRUNC('month', operation_date));
  last_date = DATE(first_date + interval '1 month' - interval '1 Day');

  -- -- 3.締日付算出
  IF rec.cut_off_day < EXTRACT(day FROM operation_date) THEN
    -- 処理日が締日を過ぎている場合・・・翌月締め
    cut_off_date = DATE(first_date + interval '1 month' + cutoff_day_interval);
  ELSIF EXTRACT(day FROM last_date) < rec.cut_off_day THEN
    -- 締日が当月末日よりも後(=締日99指定)の場合・・・当月末締め
    cut_off_date = last_date;
  ELSE
    -- 処理日が締日未到来の場合・・・当月締め
    cut_off_date = DATE(first_date + cutoff_day_interval);
  END IF;

  -- 4.支払月月初日付/月末日付算出
  first_date = DATE(DATE_TRUNC('month', cut_off_date) + month_interval);
  last_date = DATE(first_date + interval '1 month' - interval '1 Day');

  -- 5.入金期限日付算出
  IF EXTRACT(day FROM last_date) < rec.deposit_day THEN
    -- 支払期限日が支払月末日よりも後(=支払期限日99指定)の場合・・・月末支払
    deposit_date = last_date;
  ELSE
    deposit_date = DATE(first_date + deposit_day_interval);
  END IF;

END;
$$ LANGUAGE plpgsql;
