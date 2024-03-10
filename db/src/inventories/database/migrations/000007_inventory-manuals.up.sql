-- 月次在庫サマリ＿倉庫別:登録「前」処理
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


-- 月次在庫サマリ:登録「前」処理
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


-- 現在在庫サマリ:登録「前」処理
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


-- 在庫変動履歴:チェック制約
--  属性相関チェック制約(在庫変動種類/変動数量/変動金額)

-- Create Constraint
ALTER TABLE inventories.inventory_histories DROP CONSTRAINT IF EXISTS inventory_histories_taransaction_type_check;
ALTER TABLE inventories.inventory_histories ADD CONSTRAINT inventory_histories_taransaction_type_check CHECK (
  CASE
    -- 在庫変動種類が「倉庫間移動入庫」「仕入入庫」「売上返品入庫」の場合、変動数量が1以上であること
    WHEN taransaction_type='MOVE_WEARHOUSEMENT' AND variable_quantity <= 0 THEN FALSE
    WHEN taransaction_type='PURCHASE' AND variable_quantity <= 0 THEN FALSE
    WHEN taransaction_type='SALES_RETURN' AND variable_quantity <= 0 THEN FALSE
    -- 在庫変動種類が「倉庫間移動出庫」「売上出庫」「仕入返品出庫」の場合、変動数量が-1以下であること
    WHEN taransaction_type='MOVE_SHIPPMENT' AND variable_quantity >= 0 THEN FALSE
    WHEN taransaction_type='SELES' AND variable_quantity >= 0 THEN FALSE
    WHEN taransaction_type='ORDER_RETURN' AND variable_quantity >= 0 THEN FALSE
    -- 在庫変動種類が「倉庫間移動入庫」「倉庫間移動出庫」の場合、変動金額が0であること
    WHEN taransaction_type='MOVE_WEARHOUSEMENT' AND variable_amount != 0.00 THEN FALSE
    WHEN taransaction_type='MOVE_SHIPPMENT' AND variable_amount != 0.00 THEN FALSE
    -- 在庫変動種類が「仕入入庫」「売上返品入庫」の場合、変動金額が0より大きい値であること
    WHEN taransaction_type='PURCHASE' AND variable_amount <= 0.00 THEN FALSE
    WHEN taransaction_type='SALES_RETURN' AND variable_amount <= 0.00 THEN FALSE
    -- 在庫変動種類が「売上出庫」「仕入返品出庫」の場合、変動金額が0より小さい値であること
    WHEN taransaction_type='SELES' AND variable_amount >= 0.00 THEN FALSE
    WHEN taransaction_type='ORDER_RETURN' AND variable_amount >= 0.00 THEN FALSE
    ELSE TRUE
  END
);


-- 在庫変動履歴:登録「前」処理
--  有効桁数調整(変動金額)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.inventory_histories_pre_process() RETURNS TRIGGER AS $$
BEGIN
--  有効桁数調整(変動金額)
  NEW.variable_amount = ROUND(NEW.variable_amount, 2);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  BEFORE INSERT
  ON inventories.inventory_histories
  FOR EACH ROW
EXECUTE PROCEDURE inventories.inventory_histories_pre_process();

-- -- 在庫変動履歴:登録後処理
-- --  導出属性の算出(原価)
-- --  有効桁数調整(在庫金額)

-- -- Create Function
-- CREATE OR REPLACE FUNCTION inventories.current_summaries_registration_post_process() RETURNS TRIGGER AS $$
-- BEGIN
-- --  有効桁数調整(在庫金額)
--   NEW.present_amount = ROUND(NEW.present_amount, 2);
--   -- 導出属性の算出(原価)
--   IF (NEW.present_quantity = 0) THEN
--     NEW.cost_price = null;
--   ELSE
--     NEW.cost_price = ROUND(NEW.present_amount / NEW.present_quantity, 2);
--   END IF;
--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- -- Create Trigger
-- CREATE TRIGGER post_process
--   BEFORE INSERT OR UPDATE
--   ON inventories.current_inventory_summaries
--   FOR EACH ROW
-- EXECUTE PROCEDURE inventories.current_summaries_registration_post_process();
