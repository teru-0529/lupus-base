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

## サンプルデータ登録SQL(inventory) TODO:消去予定

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
INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','DAMAGED', -1, -3000, 'PURCHASE_RETURN',999,default,default,'101004-P0673822','101004-P0673822');
correct_inventory_instructions-- INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','DAMAGED', 0, -100, 'OTHER',999,default,default,'101004-P0673822','101004-P0673822');
INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','ALOCATABLE', -3, -9000, 'SELES',999,default,default,'101005-P0673822','101005-P0673822');
-- 4/6
UPDATE business_date SET present_date = '2024-04-06' WHERE business_date_type = 'BASE';
INSERT INTO inventories.correct_inventory_instructions VALUES (default,default,default,'P0673822','譲与による入荷','ALOCATABLE','AAA002001E',1, 2500,default,default,'101006-P0673822','101006-P0673822');
-- INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','ALOCATABLE', 1, 2500, 'OTHER',999,default,default,'101006-P0673822','101006-P0673822');
INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','ALOCATABLE', 2, 6000, 'SALES_RETURN',999,default,default,'101007-P0673822','101007-P0673822');
INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','ALOCATABLE', -2, -6000, 'SELES',999,default,default,'101008-P0673822','101008-P0673822');

UPDATE business_date SET present_date = '2024-03-10' WHERE business_date_type = 'BASE';
INSERT INTO inventories.inventory_histories VALUES (default,default,default,'AAA002001E','ALOCATABLE', 1, 3500, 'PURCHASE',888,default,default,'101009-P0673822','101009-P0673822');
INSERT INTO inventories.inventory_histories VALUES (default,'2024-02-01',default,'AAA002001E','ALOCATABLE', 2, 6400, 'PURCHASE',888,default,default,'101010-P0673822','101010-P0673822');
INSERT INTO inventories.inventory_histories VALUES (default,'2024-03-01',default,'AAA002001E','ALOCATABLE',-6, -18000, 'SELES',888,default,default,'101011-P0673822','101011-P0673822');
```

## サンプルデータ登録SQL(transactions)

``` SQL
-- ◆◆◆発注◆◆◆
-- ORDERINGS-1
UPDATE business_date SET present_date = '2024-02-26' WHERE business_date_type = 'BASE';
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100101-P0673822','100101-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000001','AAA002001E',5,0,0,0,default,default,default,default,default,default,'100101-P0673822','100101-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000001','AAA002002S',7,0,0,0,10500,default,default,default,default,default,'100101-P0673822','100101-P0673822');

-- ORDERINGS-1 納期変更
UPDATE business_date SET present_date = '2024-02-28' WHERE business_date_type = 'BASE';
INSERT INTO inventories.order_arrival_change_instructions VALUES (default,default,default,'P0673822','仕入先都合','PO-0000001','AAA002001E','2024-03-15',default,default,'100102-P0673822','100102-P0673822');

-- ORDERINGS-1 キャンセル
UPDATE business_date SET present_date = '2024-03-01' WHERE business_date_type = 'BASE';
INSERT INTO inventories.order_cancel_instructions VALUES (default,default,default,'P0673822','オーダーミス','PO-0000001','AAA002002S',3,default,default,'100103-P0673822','100103-P0673822');

-- ORDERINGS-2
UPDATE business_date SET present_date = '2024-03-05' WHERE business_date_type = 'BASE';
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100104-P0673822','100104-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000002','AAA002001E',3,0,0,0,5800,default,default,default,default,default,'100104-P0673822','100104-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000002','AAA002025S',4,0,0,0,default,default,default,default,default,default,'100104-P0673822','100104-P0673822');

-- ORDERINGS-3
UPDATE business_date SET present_date = '2024-03-15' WHERE business_date_type = 'BASE';
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100105-P0673822','100105-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000003','AAA002001E',2,0,0,0,default,default,default,default,default,default,'100105-P0673822','100105-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000003','AAA002002S',2,0,0,0,default,default,default,default,default,default,'100105-P0673822','100105-P0673822');

-- ORDERINGS-4
UPDATE business_date SET present_date = '2024-03-25' WHERE business_date_type = 'BASE';
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100106-P0673822','100106-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000004','AAA002001E',3,0,0,0,default,default,default,default,default,default,'100106-P0673822','100106-P0673822');

-- ORDERINGS-5
UPDATE business_date SET present_date = '2024-03-27' WHERE business_date_type = 'BASE';
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100107-P0673822','100107-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000005','AAA002002S',4,0,0,0,default,default,default,default,default,default,'100107-P0673822','100107-P0673822');

-- ORDERINGS-6
UPDATE business_date SET present_date = '2024-04-03' WHERE business_date_type = 'BASE';
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00102',NULL,default,default,'100108-P0673822','100108-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000006','BBB054792F',10,0,0,0,default,default,default,default,default,default,'100108-P0673822','100108-P0673822');


-- ◆◆◆入荷◆◆◆
-- WAREHOUSINGS-1 発注1の一部入荷
UPDATE business_date SET present_date = '2024-03-05' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100201-P0673822','100201-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000001','PO-0000001','AAA002002S',4,0,default,default,'INSPECTION',default,default,default,'100201-P0673822','100201-P0673822');

-- WAREHOUSINGS-2 発注1の残り＋発注2のほぼすべて（一部未納）
UPDATE business_date SET present_date = '2024-03-15' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100202-P0673822','100202-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000002','PO-0000001','AAA002001E',5,0,5000,default,'INSPECTION',default,default,default,'100202-P0673822','100202-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000002','PO-0000002','AAA002001E',1,0,default,default,'INSPECTION',default,default,default,'100202-P0673822','100202-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000002','PO-0000002','AAA002025S',4,0,default,default,'INSPECTION',default,default,default,'100202-P0673822','100202-P0673822');

-- WAREHOUSINGS-3 発注2の未納分すべて（登録忘れ締日後に過去日付で登録・金額確定前なのでOK）
UPDATE business_date SET present_date = '2024-03-22' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousings VALUES (default,'2024-03-20',default,'P0673822','E00101',default,default,default,NULL,default,default,'100203-P0673822','100203-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000003','PO-0000002','AAA002001E',2,0,5500,default,'INSPECTION',default,default,default,'100203-P0673822','100203-P0673822');

-- WAREHOUSINGS-4 発注3の入荷（締日後のため別の支払）
UPDATE business_date SET present_date = '2024-03-23' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100205-P0673822','100205-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000004','PO-0000003','AAA002002S',2,0,12000,default,'INSPECTION',default,default,default,'100205-P0673822','100205-P0673822');

-- 支払1 金額確定
UPDATE business_date SET present_date = '2024-03-25' WHERE business_date_type = 'BASE';
INSERT INTO inventories.payment_confirm_instructions VALUES (default,default,default,'P0673822',NULL,'PM-0000001',default,default,'100204-P0673822','100204-P0673822');

-- WAREHOUSINGS-5 発注3の入荷
UPDATE business_date SET present_date = '2024-03-25' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100206-P0673822','100206-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000005','PO-0000003','AAA002001E',2,0,default,default,'INSPECTION',default,default,default,'100206-P0673822','100206-P0673822');

-- WAREHOUSINGS-6 発注4発注5の入荷
UPDATE business_date SET present_date = '2024-04-04' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100207-P0673822','100207-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000006','PO-0000004','AAA002001E',3,0,5700,default,'INSPECTION',default,default,default,'100207-P0673822','100207-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000006','PO-0000005','AAA002002S',4,0,default,default,'INSPECTION',default,default,default,'100207-P0673822','100207-P0673822');

-- WAREHOUSINGS-7 発注6の入荷(一部)
UPDATE business_date SET present_date = '2024-04-08' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00102',default,default,default,NULL,default,default,'100208-P0673822','100208-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000007','PO-0000006','BBB054792F',6,0,default,default,'INSPECTION',default,default,default,'100208-P0673822','100208-P0673822');

-- 買掛修正★★★
UPDATE business_date SET present_date = '2024-04-10' WHERE business_date_type = 'BASE';
INSERT INTO inventories.correct_payable_instructions VALUES (default,default,default,'P0673822','瑕疵理由による支払減額','E00101',-20000,default,default,default,default,default,'100209-P0673822','100209-P0673822');

-- 支払3 金額確定
UPDATE business_date SET present_date = '2024-04-12' WHERE business_date_type = 'BASE';
INSERT INTO inventories.payment_confirm_instructions VALUES (default,default,default,'P0673822',NULL,'PM-0000003',default,default,'100210-P0673822','100210-P0673822');

-- 支払1 支払
UPDATE business_date SET present_date = '2024-04-20' WHERE business_date_type = 'BASE';
INSERT INTO inventories.payment_instructions VALUES (default,default,default,'P0673822',NULL,'PM-0000001',default,default,'100211-P0673822','100211-P0673822');


-- ◆◆◆在庫◆◆◆
-- 検品1 入荷1の検品
UPDATE business_date SET present_date = '2024-03-06' WHERE business_date_type = 'BASE';
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','INSPECTION','ALOCATABLE','AAA002002S',4,default,default,'100301-P0673822','100301-P0673822');

-- 検品2 入荷2/入荷3の検品(一部不良)
UPDATE business_date SET present_date = '2024-03-22' WHERE business_date_type = 'BASE';
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','INSPECTION','ALOCATABLE','AAA002001E',7,default,default,'100302-P0673822','100302-P0673822');
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品不良品','INSPECTION','DAMAGED','AAA002001E',1,default,default,'100303-P0673822','100303-P0673822');
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','INSPECTION','ALOCATABLE','AAA002025S',4,default,default,'100304-P0673822','100304-P0673822');

-- 検品3 入荷4の検品
UPDATE business_date SET present_date = '2024-03-24' WHERE business_date_type = 'BASE';
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','INSPECTION','ALOCATABLE','AAA002002S',2,default,default,'100305-P0673822','100305-P0673822');

-- 入荷2の返品（不良品）/瑕疵分の損失計上
UPDATE business_date SET present_date = '2024-03-25' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousing_return_instructions VALUES (default,default,default,'P0673822','不良品の返品','WH-0000002','PO-0000002','AAA002001E','DAMAGED',1,3000,default,default,'PM-0000001',default,default,'100306-P0673822','100306-P0673822');

INSERT INTO inventories.correct_inventory_instructions VALUES (default,default,default,'P0673822','当社瑕疵分損失計上','DAMAGED','AAA002001E',0,-2000,default,default,'100307-P0673822','100307-P0673822');

-- 検品4 入荷5の検品
UPDATE business_date SET present_date = '2024-03-26' WHERE business_date_type = 'BASE';
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','INSPECTION','ALOCATABLE','AAA002001E',2,default,default,'100308-P0673822','100308-P0673822');

-- 検品5 入荷6の検品
UPDATE business_date SET present_date = '2024-04-05' WHERE business_date_type = 'BASE';
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','INSPECTION','ALOCATABLE','AAA002001E',3,default,default,'100309-P0673822','100309-P0673822');
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','INSPECTION','ALOCATABLE','AAA002002S',4,default,default,'100310-P0673822','100310-P0673822');

-- その他処理
UPDATE business_date SET present_date = '2024-04-06' WHERE business_date_type = 'BASE';
INSERT INTO inventories.correct_inventory_instructions VALUES (default,default,default,'P0673822','譲与による入荷','ALOCATABLE','AAA002001E',1, 5100,default,default,'100311-P0673822','100311-P0673822');

-- 検品6 入荷7の検品
UPDATE business_date SET present_date = '2024-04-09' WHERE business_date_type = 'BASE';
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','INSPECTION','ALOCATABLE','BBB054792F',4,default,default,'100312-P0673822','100312-P0673822');
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品不良品','INSPECTION','DAMAGED','BBB054792F',2,default,default,'100313-P0673822','100313-P0673822');

-- 入荷7の返品(不良品)
UPDATE business_date SET present_date = '2024-04-13' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousing_return_instructions VALUES (default,default,default,'P0673822','不良品の返品','WH-0000007','PO-0000006','BBB054792F','DAMAGED',2,default,default,default,'PM-0000003',default,default,'100314-P0673822','100314-P0673822');
```
