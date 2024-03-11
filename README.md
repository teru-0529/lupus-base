# lupus-base

おおかみ座Lupus(ループス)
(在庫管理アプリケーションベース)

## サンプルデータ登録SQL(material)

``` SQL
-- 倉庫
INSERT INTO inventories.inventory_sites VALUES ('ALOCATABLE', 'P0673822', True,default,default,'111111-P0673822','111111-P0673822');
INSERT INTO inventories.inventory_sites VALUES ('KEEP', 'P0673822', False,default,default,'111111-P0673822','111111-P0673822');
INSERT INTO inventories.inventory_sites VALUES ('INSPACTTIN', 'P0673822', False,default,default,'111111-P0673822','111111-P0673822');
INSERT INTO inventories.inventory_sites VALUES ('DAMAGED', 'P0673822', False,default,default,'111111-P0673822','111111-P0673822');
INSERT INTO inventories.inventory_sites VALUES ('PRIVATE_ORDER', 'P0673822', False,default,default,'111111-P0673822','111111-P0673822');

-- 企業・取引銀行・得意先・仕入先
INSERT INTO inventories.companies VALUES ('E00101','織田物産','171-0022','東京都豊島区南池袋１丁目',null,null,null,default,default,'111111-P0673822','111111-P0673822');
INSERT INTO inventories.companies VALUES ('E00202','徳川商事','100-0005','東京都千代田区丸の内１丁目',null,null,null,default,default,'111111-P0673822','111111-P0673822');

INSERT INTO inventories.dealing_banks VALUES ('E00101','0001','みずほ銀行','123','12345-0756832',default,default,'111141-P0673822','111141-P0673822');

INSERT INTO inventories.costomers VALUES ('E00101','ACTIVE',5,1,99,'P0673822','織田信雄',null,default,default,'111112-P0673822','111112-P0673822');

INSERT INTO inventories.suppliers VALUES ('E00101','ACTIVE',10,2,15,'P0673822','織田信長','AS_NEEDED',null,10,null,default,default,'111112-P0673822','111112-P0673822');
INSERT INTO inventories.suppliers VALUES ('E00202',default,default,default,default,'P0673822','徳川家康','PERIODICALLY',4,20,'来月取引開始を目標に調整中',default,default,'111112-P0673822','111112-P0673822');

-- 商品
INSERT INTO inventories.products VALUES ('AAA002001E','E00101','ARZ29854-SEDX-02','シャンプー','ACTIVE',10000,3000,default,5,default,default,'111113-P0673822','111113-P0673822');
INSERT INTO inventories.products VALUES ('AAA002002S','E00101','ARZ29561-SBGI-04','台所用洗剤','STOP_DEALING',0,2700,default,8,default,default,'111113-P0673822','111113-P0673822');
UPDATE inventories.products SET selling_price = 4500.00, updated_by = '111125-P0673822'  WHERE product_id = 'AAA002002S';

-- 送付先
INSERT INTO inventories.company_destinations VALUES (default, 'E00101','160-0022','東京都新宿区新宿３丁目３８−１',null,null,default,default,'333333-P0673822','333333-P0673822');
INSERT INTO inventories.company_destinations VALUES (default, 'E00101','330-0853','埼玉県さいたま市大宮区錦町',null,null,default,default,'333333-P0673822','333333-P0673822');
INSERT INTO inventories.company_destinations VALUES (default, 'E00101','980-0021','宮城県仙台市青葉区中央１丁目１−１',null,null,default,default,'333333-P0673822','333333-P0673822');
```

## サンプルデータ登録SQL(inventory)

``` SQL
DELETE FROM inventories.inventory_histories;
DELETE FROM inventories.month_inventory_summaries_every_site;
DELETE FROM inventories.month_inventory_summaries;
DELETE FROM inventories.current_inventory_summaries_every_site;
DELETE FROM inventories.current_inventory_summaries;
-- 3/20
UPDATE business_date SET present_date = '2024-03-20' WHERE business_date_type = 'BASE';
INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','INSPACTTIN', 6, 18100, 'PURCHASE',999,default,default,'101001-P0673822','101001-P0673822');
-- 3/25
UPDATE business_date SET present_date = '2024-03-25' WHERE business_date_type = 'BASE';
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','INSPACTTIN','ALOCATABLE','AAA002001E',5,default,default,'101002-P0673822','101002-P0673822');
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品不良品','INSPACTTIN','DAMAGED','AAA002001E',1,default,default,'101003-P0673822','101003-P0673822');
-- INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','INSPACTTIN', -5, 0, 'MOVE_SHIPPMENT',999,default,default,'101002-P0673822','101002-P0673822');
-- INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','ALOCATABLE', 5, 0, 'MOVE_WAREHOUSEMENT',999,default,default,'101002-P0673822','101002-P0673822');
-- INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','INSPACTTIN', -1, 0, 'MOVE_SHIPPMENT',999,default,default,'101003-P0673822','101003-P0673822');
-- INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','DAMAGED', 1, 0, 'MOVE_WAREHOUSEMENT',999,default,default,'101003-P0673822','101003-P0673822');
-- 4/5
UPDATE business_date SET present_date = '2024-04-05' WHERE business_date_type = 'BASE';
INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','DAMAGED', -1, -3000, 'ORDER_RETURN',999,default,default,'101004-P0673822','101004-P0673822');
INSERT INTO inventories.other_inventory_instructions VALUES (default,default,default,'P0673822','当社瑕疵損失','DAMAGED','AAA002001E',0,-100,default,default,'101004-P0673822','101004-P0673822');
-- INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','DAMAGED', 0, -100, 'OTHER',999,default,default,'101004-P0673822','101004-P0673822');
INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','ALOCATABLE', -3, -9000, 'SELES',999,default,default,'101005-P0673822','101005-P0673822');
-- 4/6
UPDATE business_date SET present_date = '2024-04-06' WHERE business_date_type = 'BASE';
INSERT INTO inventories.other_inventory_instructions VALUES (default,default,default,'P0673822','譲与による入荷','ALOCATABLE','AAA002001E',1, 2500,default,default,'101006-P0673822','101006-P0673822');
-- INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','ALOCATABLE', 1, 2500, 'OTHER',999,default,default,'101006-P0673822','101006-P0673822');
INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','ALOCATABLE', 2, 6000, 'SALES_RETURN',999,default,default,'101007-P0673822','101007-P0673822');
INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','ALOCATABLE', -2, -6000, 'SELES',999,default,default,'101008-P0673822','101008-P0673822');

UPDATE business_date SET present_date = '2024-03-10' WHERE business_date_type = 'BASE';
INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','ALOCATABLE', 1, 3500, 'PURCHASE',888,default,default,'101009-P0673822','101009-P0673822');
INSERT INTO inventories.inventory_histories VALUES (default,'2024-02-01',default,'AAA002001E','ALOCATABLE', 2, 6400, 'PURCHASE',888,default,default,'101010-P0673822','101010-P0673822');
INSERT INTO inventories.inventory_histories VALUES (default,'2024-03-01',default,'AAA002001E','ALOCATABLE',-6, -18000, 'SELES',888,default,default,'101011-P0673822','101011-P0673822');
```
