-- 月次在庫サマリ＿倉庫別:登録「前」処理
--  導出属性の算出(在庫数量)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.month_summaries_es_pre_process() RETURNS TRIGGER AS $$
BEGIN
  -- 導出属性の算出(在庫数量)
  NEW.present_quantity = NEW.init_quantity + NEW.warehousing_quantity - NEW.shipping_quantity;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.month_inventory_summaries_every_site
  FOR EACH ROW
EXECUTE PROCEDURE inventories.month_summaries_es_pre_process();


-- 月次在庫サマリ:登録「前」処理
--  導出属性の算出(在庫数量/在庫金額/原価)
--  有効桁数調整(月初金額/入庫金額/出庫金額)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.month_summaries_pre_process() RETURNS TRIGGER AS $$
BEGIN
  -- 有効桁数調整(月初金額/入庫金額/出庫金額)
  NEW.init_amount = ROUND(NEW.init_amount, 2);
  NEW.warehousing_amount = ROUND(NEW.warehousing_amount, 2);
  NEW.shipping_amount = ROUND(NEW.shipping_amount, 2);
  -- 導出属性の算出(在庫数量)
  NEW.present_quantity = NEW.init_quantity + NEW.warehousing_quantity - NEW.shipping_quantity;
  -- 導出属性の算出(在庫金額)
  NEW.present_amount = ROUND(NEW.init_amount + NEW.warehousing_amount - NEW.shipping_amount, 2);
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
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.month_inventory_summaries
  FOR EACH ROW
EXECUTE PROCEDURE inventories.month_summaries_pre_process();


-- 現在在庫サマリ:登録「前」処理
--  導出属性の算出(原価)
--  有効桁数調整(在庫金額)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.current_summaries_pre_process() RETURNS TRIGGER AS $$
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
CREATE TRIGGER pre_process
  BEFORE INSERT OR UPDATE
  ON inventories.current_inventory_summaries
  FOR EACH ROW
EXECUTE PROCEDURE inventories.current_summaries_pre_process();


-- 在庫変動履歴:チェック制約
--  属性相関チェック制約(在庫変動種類/変動数量/変動金額)

-- Create Constraint
ALTER TABLE inventories.inventory_histories DROP CONSTRAINT IF EXISTS inventory_histories_inventory_type_check;
ALTER TABLE inventories.inventory_histories ADD CONSTRAINT inventory_histories_inventory_type_check CHECK (
  CASE
    -- 在庫変動種類が「倉庫間移動入庫」「仕入入庫」「売上返品入庫」の場合、変動数量が1以上であること
    WHEN inventory_type = 'MOVE_WAREHOUSEMENT' AND variable_quantity <= 0 THEN FALSE
    WHEN inventory_type = 'PURCHASE' AND variable_quantity <= 0 THEN FALSE
    WHEN inventory_type = 'SALES_RETURN' AND variable_quantity <= 0 THEN FALSE
    -- 在庫変動種類が「倉庫間移動出庫」「売上出庫」「仕入返品出庫」の場合、変動数量が-1以下であること
    WHEN inventory_type = 'MOVE_SHIPPMENT' AND variable_quantity >= 0 THEN FALSE
    WHEN inventory_type = 'SELES' AND variable_quantity >= 0 THEN FALSE
    WHEN inventory_type = 'ORDER_RETURN' AND variable_quantity >= 0 THEN FALSE
    -- 在庫変動種類が「倉庫間移動入庫」「倉庫間移動出庫」の場合、変動金額が0であること
    WHEN inventory_type = 'MOVE_WAREHOUSEMENT' AND variable_amount != 0.00 THEN FALSE
    WHEN inventory_type = 'MOVE_SHIPPMENT' AND variable_amount != 0.00 THEN FALSE
    -- 在庫変動種類が「仕入入庫」「売上返品入庫」の場合、変動金額が0より大きい値であること
    WHEN inventory_type = 'PURCHASE' AND variable_amount <= 0.00 THEN FALSE
    WHEN inventory_type = 'SALES_RETURN' AND variable_amount <= 0.00 THEN FALSE
    -- 在庫変動種類が「売上出庫」「仕入返品出庫」の場合、変動金額が0より小さい値であること
    WHEN inventory_type = 'SELES' AND variable_amount >= 0.00 THEN FALSE
    WHEN inventory_type = 'ORDER_RETURN' AND variable_amount >= 0.00 THEN FALSE
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
CREATE TRIGGER pre_process
  BEFORE INSERT
  ON inventories.inventory_histories
  FOR EACH ROW
EXECUTE PROCEDURE inventories.inventory_histories_pre_process();


-- 在庫変動履歴:登録「後」処理
--  別テーブル登録/更新(月次在庫サマリ＿倉庫別/月次在庫サマリ/現在在庫サマリ＿倉庫別/現在在庫サマリ)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.upsert_inventory_summaries() RETURNS TRIGGER AS $$
DECLARE
  yyyymm text:=to_char(NEW.business_date, 'YYYYMM');

  t_init_quantity integer;
  t_warehousing_quantity integer;
  t_shipping_quantity integer;
  t_init_amount numeric;
  t_warehousing_amount numeric;
  t_shipping_amount numeric;

  recent_rec RECORD; --検索結果レコード(現在年月)
  last_rec RECORD;--検索結果レコード(過去最新年月)
  rec RECORD;
BEGIN
--  1.月次在庫サマリ＿倉庫別 INFO:

  -- 1.1.現在年月データの取得
  SELECT * INTO recent_rec
    FROM inventories.month_inventory_summaries_every_site
    WHERE product_id = NEW.product_id AND site_id = NEW.site_id AND year_month = yyyymm
    FOR UPDATE;

  -- 1.2.月初数量/入庫数量/出庫数量の算出
  IF recent_rec IS NULL THEN
    -- 現在年月データが存在しないケース
    -- 過去最新在庫数の取得
    SELECT * INTO last_rec
      FROM inventories.month_inventory_summaries_every_site
      WHERE product_id = NEW.product_id AND site_id = NEW.site_id AND year_month < yyyymm
      ORDER BY year_month DESC
      LIMIT 1;
    -- 過去最新在庫数が取得できた場合は月初数量に設定
    t_init_quantity:=CASE WHEN last_rec IS NULL THEN 0 ELSE last_rec.present_quantity END;
    t_warehousing_quantity:=0;
    t_shipping_quantity:=0;
  ELSE
    -- 現在年月データが存在するケース
    t_init_quantity:=recent_rec.init_quantity;
    t_warehousing_quantity:=recent_rec.warehousing_quantity;
    t_shipping_quantity:=recent_rec.shipping_quantity;
  END IF;

  -- 1.3.取引数量の計上(変動数量の符号により判断)
  IF NEW.variable_quantity > 0 THEN
    t_warehousing_quantity:=t_warehousing_quantity + NEW.variable_quantity;
  ELSE
    t_shipping_quantity:=t_shipping_quantity - NEW.variable_quantity;
  END IF;

  -- 1.4.登録/更新
  IF recent_rec IS NULL THEN
    -- 現在年月データが存在しないケース
    INSERT INTO inventories.month_inventory_summaries_every_site VALUES (
      NEW.product_id,
      yyyymm,
      NEW.site_id,
      t_init_quantity,
      t_warehousing_quantity,
      t_shipping_quantity,
      default,
      default,
      default,
      NEW.created_by,
      NEW.created_by
    );
  ELSE
    -- 現在年月データが存在するケース
    UPDATE inventories.month_inventory_summaries_every_site
    SET warehousing_quantity = t_warehousing_quantity,
        shipping_quantity = t_shipping_quantity
    WHERE product_id = NEW.product_id AND site_id = NEW.site_id AND year_month = yyyymm;
  END IF;

  -- 1.5.現在年月以降のデータ更新(存在する場合)
  FOR rec IN SELECT * FROM inventories.month_inventory_summaries_every_site
    WHERE product_id = NEW.product_id AND site_id = NEW.site_id AND year_month > yyyymm LOOP

    UPDATE inventories.month_inventory_summaries_every_site
    SET init_quantity = rec.init_quantity + NEW.variable_quantity
    WHERE product_id = NEW.product_id AND site_id = NEW.site_id AND year_month = rec.year_month;
  END LOOP;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

--  2.現在在庫サマリ＿倉庫別 INFO:

  -- 2.1.最新データの取得
  SELECT * INTO recent_rec
    FROM inventories.current_inventory_summaries_every_site
    WHERE product_id = NEW.product_id AND site_id = NEW.site_id
    FOR UPDATE;

  -- 2.2.登録/更新
  IF recent_rec IS NULL THEN
    -- 最新データが存在しないケース
    INSERT INTO inventories.current_inventory_summaries_every_site VALUES (
      NEW.product_id,
      NEW.site_id,
      NEW.variable_quantity,
      default,
      default,
      NEW.created_by,
      NEW.created_by
    );
  ELSE
    -- 最新データが存在するケース
    UPDATE inventories.current_inventory_summaries_every_site
    SET present_quantity = recent_rec.present_quantity + NEW.variable_quantity
    WHERE product_id = NEW.product_id AND site_id = NEW.site_id;
  END IF;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

-- 倉庫間移動は在庫内で動きのためここで抜ける
  IF NEW.inventory_type = 'MOVE_WAREHOUSEMENT' OR NEW.inventory_type = 'MOVE_SHIPPMENT' THEN
    RETURN NEW;
  END IF;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
--  3.月次在庫サマリー INFO:

  -- 3.1.現在年月データの取得
  SELECT * INTO recent_rec
    FROM inventories.month_inventory_summaries
    WHERE product_id = NEW.product_id AND year_month = yyyymm
    FOR UPDATE;

  -- 3.2.月初数量/入庫数量/出庫数量/月初金額/入庫金額/出庫金額の算出
  IF recent_rec IS NULL THEN
    -- 現在年月データが存在しないケース
    -- 過去最新在庫数/過去最新在庫金額の取得
    SELECT * INTO last_rec
      FROM inventories.month_inventory_summaries
      WHERE product_id = NEW.product_id AND year_month < yyyymm
      ORDER BY year_month DESC
      LIMIT 1;
    -- 過去最新在庫数/過去最新在庫金額が取得できた場合は月初数量/月初金額に設定
    t_init_quantity:=CASE WHEN last_rec IS NULL THEN 0 ELSE last_rec.present_quantity END;
    t_warehousing_quantity:=0;
    t_shipping_quantity:=0;
    t_init_amount:=CASE WHEN last_rec IS NULL THEN 0.00 ELSE last_rec.present_amount END;
    t_warehousing_amount:=0.00;
    t_shipping_amount:=0.00;
  ELSE
    -- 現在年月データが存在するケース
    t_init_quantity:=recent_rec.init_quantity;
    t_warehousing_quantity:=recent_rec.warehousing_quantity;
    t_shipping_quantity:=recent_rec.shipping_quantity;
    t_init_amount:=recent_rec.init_amount;
    t_warehousing_amount:=recent_rec.warehousing_amount;
    t_shipping_amount:=recent_rec.shipping_amount;
  END IF;

  -- 3.3.取引数量/取引金額の計上(変動数量/変動金額の符号により判断)
  IF NEW.variable_quantity > 0 THEN
    t_warehousing_quantity:=t_warehousing_quantity + NEW.variable_quantity;
  ELSE
    t_shipping_quantity:=t_shipping_quantity - NEW.variable_quantity;
  END IF;
  IF NEW.variable_amount > 0 THEN
    t_warehousing_amount:=t_warehousing_amount + NEW.variable_amount;
  ELSE
    t_shipping_amount:=t_shipping_amount - NEW.variable_amount;
  END IF;

  -- 3.4.登録/更新
  IF recent_rec IS NULL THEN
    -- 現在年月データが存在しないケース
    INSERT INTO inventories.month_inventory_summaries VALUES (
      NEW.product_id,
      yyyymm,
      t_init_quantity,
      t_warehousing_quantity,
      t_shipping_quantity,
      default,
      t_init_amount,
      t_warehousing_amount,
      t_shipping_amount,
      default,
      default,
      default,
      default,
      NEW.created_by,
      NEW.created_by
    );
  ELSE
    -- 現在年月データが存在するケース
    UPDATE inventories.month_inventory_summaries
    SET warehousing_quantity = t_warehousing_quantity,
        shipping_quantity = t_shipping_quantity,
        warehousing_amount = t_warehousing_amount,
        shipping_amount = t_shipping_amount
    WHERE product_id = NEW.product_id AND year_month = yyyymm;
  END IF;

  -- 1.5.現在年月以降のデータ更新(存在する場合)
  FOR rec IN SELECT * FROM inventories.month_inventory_summaries
    WHERE product_id = NEW.product_id AND year_month > yyyymm LOOP

    UPDATE inventories.month_inventory_summaries
    SET init_quantity = rec.init_quantity + NEW.variable_quantity,
        init_amount = rec.init_amount + NEW.variable_amount
    WHERE product_id = NEW.product_id AND year_month = rec.year_month;
  END LOOP;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
--  4.現在在庫サマリー INFO:

  -- 4.1.最新データの取得
  SELECT * INTO recent_rec
    FROM inventories.current_inventory_summaries
    WHERE product_id = NEW.product_id
    FOR UPDATE;

  -- 4.2.登録/更新
  IF recent_rec IS NULL THEN
    -- 最新データが存在しないケース
    INSERT INTO inventories.current_inventory_summaries VALUES (
      NEW.product_id,
      NEW.variable_quantity,
      NEW.variable_amount,
      default,
      default,
      default,
      NEW.created_by,
      NEW.created_by
    );
  ELSE
    -- 最新データが存在するケース
    UPDATE inventories.current_inventory_summaries
    SET present_quantity = recent_rec.present_quantity + NEW.variable_quantity,
        present_amount = recent_rec.present_amount + NEW.variable_amount
    WHERE product_id = NEW.product_id;
  END IF;

----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER post_process
  AFTER INSERT
  ON inventories.inventory_histories
  FOR EACH ROW
EXECUTE PROCEDURE inventories.upsert_inventory_summaries();


-- 雑入出庫指示:登録「前」処理
--  有効桁数調整(変動金額)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.other_instruction_pre_process() RETURNS TRIGGER AS $$
BEGIN
--  有効桁数調整(変動金額)
  NEW.variable_amount = ROUND(NEW.variable_amount, 2);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create Trigger
CREATE TRIGGER pre_process
  BEFORE INSERT
  ON inventories.other_inventory_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.other_instruction_pre_process();


-- 倉庫移動指示:登録「後」処理
--  別テーブル登録(在庫変動履歴)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.insert_move_inventory_history() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO inventories.inventory_histories
  VALUES (
    default,
    NEW.business_date,
    NEW.operation_timestamp,
    NEW.product_id,
    NEW.site_id_from,
    - NEW.quantity,
    0.00,
    'MOVE_SHIPPMENT',
    NEW.move_instruction_no,
    default,
    default,
    NEW.created_by,
    NEW.created_by
  );

  INSERT INTO inventories.inventory_histories
  VALUES (
    default,
    NEW.business_date,
    NEW.operation_timestamp,
    NEW.product_id,
    NEW.site_id_to,
    NEW.quantity,
    0.00,
    'MOVE_WAREHOUSEMENT',
    NEW.move_instruction_no,
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
  ON inventories.moving_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.insert_move_inventory_history();


-- 雑入出庫指示:登録「後」処理
--  別テーブル登録(在庫変動履歴)

-- Create Function
CREATE OR REPLACE FUNCTION inventories.insert_other_inventory_history() RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO inventories.inventory_histories
  VALUES (
    default,
    NEW.business_date,
    NEW.operation_timestamp,
    NEW.product_id,
    NEW.site_id,
    NEW.variable_quantity,
    NEW.variable_amount,
    'OTHER',
    NEW.other_inventory_instruction_no,
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
  ON inventories.other_inventory_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.insert_other_inventory_history();




-- SAMPLE DATA
-- 倉庫
INSERT INTO inventories.inventory_sites VALUES ('ALOCATABLE', 'P0673822', True,default,default,'100001-P0673822','100001-P0673822');
INSERT INTO inventories.inventory_sites VALUES ('KEEP', 'P0673822', False,default,default,'100001-P0673822','100001-P0673822');
INSERT INTO inventories.inventory_sites VALUES ('INSPECTION', 'P0673822', False,default,default,'100001-P0673822','100001-P0673822');
INSERT INTO inventories.inventory_sites VALUES ('DAMAGED', 'P0673822', False,default,default,'100001-P0673822','100001-P0673822');
INSERT INTO inventories.inventory_sites VALUES ('PRIVATE_ORDER', 'P0673822', False,default,default,'100001-P0673822','100001-P0673822');

-- 企業
INSERT INTO inventories.companies VALUES ('E00101','織田物産','171-0022','東京都豊島区南池袋１丁目',null,null,null,default,default,'100002-P0673822','100002-P0673822');
INSERT INTO inventories.companies VALUES ('E00102','豊臣興業','060-0806','北海道札幌市北区北６条西４丁目',null,null,null,default,default,'100002-P0673822','100002-P0673822');
INSERT INTO inventories.companies VALUES ('S00201','徳川商事','100-0005','東京都千代田区丸の内１丁目',null,null,null,default,default,'100002-P0673822','100002-P0673822');
INSERT INTO inventories.companies VALUES ('S00202','武田物流','400-0031','山梨県甲府市丸の内１丁目',null,null,null,default,default,'100002-P0673822','100002-P0673822');

-- 取引銀行
INSERT INTO inventories.dealing_banks VALUES ('E00101','0001','みずほ銀行','123','12345-0756832',default,default,'100003-P0673822','100003-P0673822');
INSERT INTO inventories.dealing_banks VALUES ('E00102','0005','三菱ＵＦＪ銀行','318','12345-0756832',default,default,'100003-P0673822','100003-P0673822');
INSERT INTO inventories.dealing_banks VALUES ('S00201','0009','三井住友銀行','546','12345-0756832',default,default,'100003-P0673822','100003-P0673822');

-- 仕入先
INSERT INTO inventories.suppliers VALUES ('E00101','ACTIVE',20,1,99,'P0673822','織田信長','AS_NEEDED',null,10,null,default,default,'100005-P0673822','100005-P0673822');
INSERT INTO inventories.suppliers VALUES ('E00102','ACTIVE',10,1,15,'P0673822','豊臣秀吉','PERIODICALLY',3,5,null,default,default,'100005-P0673822','100005-P0673822');

-- 得意先
INSERT INTO inventories.costomers VALUES ('E00101','ACTIVE',5,1,99,'P0673822','織田信雄',null,default,default,'100004-P0673822','100004-P0673822');
INSERT INTO inventories.costomers VALUES ('S00201','ACTIVE',99,2,5,'P0673822','徳川家康',null,default,default,'100004-P0673822','100004-P0673822');
INSERT INTO inventories.costomers VALUES ('S00202',default,default,default,default,'P0673822','武田信玄','来月取引開始を目標に調整中',default,default,'100004-P0673822','100004-P0673822');

-- 商品
INSERT INTO inventories.products VALUES ('AAA002001E','E00101','ARZ29854-SEDX-02','シャンプー','ACTIVE',10000,6000,default,default,default,default,'100006-P0673822','100006-P0673822');
INSERT INTO inventories.products VALUES ('AAA002002S','E00101','ARZ29561-SBGI-04','台所用洗剤','ACTIVE',13000,11000,default,8,default,default,'100006-P0673822','100006-P0673822');
INSERT INTO inventories.products VALUES ('AAA002025S','E00101','ARZ34521-TRDG-01','掃除用スポンジ','ACTIVE',8000,5500,default,default,default,default,'100006-P0673822','100006-P0673822');
INSERT INTO inventories.products VALUES ('AAA001198G','E00101','ARZ09758-GKLX-07','キッチンペーパー','STOP_DEALING',0,2700,default,default,default,default,'100006-P0673822','100006-P0673822');
INSERT INTO inventories.products VALUES ('BBB054792F','E00102','876-BX','ノート','ACTIVE',25000,18000,default,default,default,default,'100006-P0673822','100006-P0673822');

-- 企業送付先
INSERT INTO inventories.company_destinations VALUES (default, 'E00101','160-0022','東京都新宿区新宿３丁目３８−１',null,null,default,default,'100007-P0673822','100007-P0673822');
INSERT INTO inventories.company_destinations VALUES (default, 'E00101','330-0853','埼玉県さいたま市大宮区錦町',null,null,default,default,'100007-P0673822','100007-P0673822');
INSERT INTO inventories.company_destinations VALUES (default, 'E00101','980-0021','宮城県仙台市青葉区中央１丁目１−１',null,null,default,default,'100007-P0673822','100007-P0673822');
