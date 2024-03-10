-- 商品:登録後処理
--  導出属性の算出(標準利益率)
--  有効桁数調整(売価/原価)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.products_registration_post_process() RETURNS TRIGGER AS $$
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
CREATE TRIGGER post_process
  BEFORE INSERT OR UPDATE
  ON inventories.products
  FOR EACH ROW
EXECUTE PROCEDURE inventories.products_registration_post_process();


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
  DECLARE
    result integer;
  BEGIN
  -- 取引銀行のPK検索
  SELECT COUNT (1) INTO result FROM inventories.dealing_banks WHERE company_id = i_company_id;
  RETURN result > 0;
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

-- -- Create Constraint
-- ALTER TABLE inventories.suppliers DROP CONSTRAINT IF EXISTS suppliers_order_policy_check;
-- ALTER TABLE inventories.suppliers ADD CONSTRAINT suppliers_order_policy_check CHECK (
--   -- 発注方法が「定期発注」の場合、発注曜日が「必須」
--   -- 発注方法が「随時発注」の場合、発注曜日が存在してはいけない
--   CASE
--     WHEN order_policy='PERIODICALLY' AND order_week_num IS NULL THEN FALSE
--     WHEN order_policy='AS_NEEDED' AND order_week_num IS NOT NULL THEN FALSE
--     ELSE TRUE
--   END
-- );


-- Create Constraint
-- ALTER TABLE inventories.suppliers DROP CONSTRAINT IF EXISTS suppliers_order_policy_check;
-- ALTER TABLE inventories.suppliers ADD CONSTRAINT suppliers_order_policy_check CHECK (
--   -- 発注方法が「定期発注」の場合、発注曜日が「必須」
--   -- 発注方法が「随時発注」の場合、発注曜日が存在してはいけない
--   CASE
--     WHEN order_policy='PERIODICALLY' AND order_week_num IS NULL THEN FALSE
--     WHEN order_policy='AS_NEEDED' AND order_week_num IS NOT NULL THEN FALSE
--     ELSE TRUE
--   END
-- );
