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
    NEW.standard_profit_rate = ROUND((NEW.selling_price - NEW.cost_price) / NEW.selling_price, 2);
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
  ORDER BY company_id, seq_no
