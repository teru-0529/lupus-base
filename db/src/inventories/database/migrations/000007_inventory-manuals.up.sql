-- 月次在庫サマリ＿倉庫別:登録後処理
--  導出属性の算出(在庫数量)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.month_summaries_es_registration_post_process() RETURNS TRIGGER AS $$
BEGIN
  -- 導出属性の算出(在庫数量)
  NEW.present_quantity = NEW.init_quantity + NEW.wearhousing_quantity - NEW.shipping_quantity;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  BEFORE INSERT OR UPDATE
  ON inventories.month_inventory_summaries_every_site
  FOR EACH ROW
EXECUTE PROCEDURE inventories.month_summaries_es_registration_post_process();


-- 月次在庫サマリ:登録後処理
--  導出属性の算出(在庫数量/在庫金額/原価)
--  有効桁数調整(月初金額/入庫金額/出庫金額)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.month_summaries_registration_post_process() RETURNS TRIGGER AS $$
BEGIN
  -- 有効桁数調整(月初金額/入庫金額/出庫金額)
  NEW.init_amount = ROUND(NEW.init_amount, 2);
  NEW.wearhousing_amount = ROUND(NEW.wearhousing_amount, 2);
  NEW.shipping_amount = ROUND(NEW.shipping_amount, 2);
  -- 導出属性の算出(在庫数量)
  NEW.present_quantity = NEW.init_quantity + NEW.wearhousing_quantity - NEW.shipping_quantity;
  -- 導出属性の算出(在庫金額)
  NEW.present_amount = ROUND(NEW.init_amount + NEW.wearhousing_amount - NEW.shipping_amount, 2);
  -- 導出属性の算出(原価)
  IF (NEW.present_quantity = 0) THEN
    NEW.cost_price = null;
  ELSE
    NEW.cost_price = ROUND(NEW.present_amount / NEW.present_quantity, 2);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  BEFORE INSERT OR UPDATE
  ON inventories.month_inventory_summaries
  FOR EACH ROW
EXECUTE PROCEDURE inventories.month_summaries_registration_post_process();


-- 現在在庫サマリ:登録後処理
--  導出属性の算出(原価)
--  有効桁数調整(在庫金額)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.current_summaries_registration_post_process() RETURNS TRIGGER AS $$
BEGIN
--  有効桁数調整(在庫金額)
  NEW.present_amount = ROUND(NEW.present_amount, 2);
  -- 導出属性の算出(原価)
  IF (NEW.present_quantity = 0) THEN
    NEW.cost_price = null;
  ELSE
    NEW.cost_price = ROUND(NEW.present_amount / NEW.present_quantity, 2);
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  BEFORE INSERT OR UPDATE
  ON inventories.current_inventory_summaries
  FOR EACH ROW
EXECUTE PROCEDURE inventories.current_summaries_registration_post_process();
