# lupus-base

おおかみ座Lupus(ループス)
(在庫管理アプリケーションベース)

## サンプルデータ登録SQL(material)

``` SQL
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
