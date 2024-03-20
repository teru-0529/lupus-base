# lupus-base

おおかみ座Lupus(ループス)
(在庫管理アプリケーションベース)

## サンプルデータ登録SQL(material)

``` SQL
-- 倉庫
INSERT INTO inventories.inventory_sites VALUES ('USUALLY','P0673822','ALLOWABLE',NULL,default,default,'100001-P0673822','100001-P0673822');
INSERT INTO inventories.inventory_sites VALUES ('ON_INSPECT','P0673822','INSPECT',NULL,default,default,'100001-P0673822','100001-P0673822');
INSERT INTO inventories.inventory_sites VALUES ('DEFECTIVE_INSPECTION','P0673822','KEEP','検品不良品(一時待機用)',default,default,'100001-P0673822','100001-P0673822');
INSERT INTO inventories.inventory_sites VALUES ('SHIPPING_RETURN','P0673822','KEEP','出荷返品(一時待機用)',default,default,'100001-P0673822','100001-P0673822');
INSERT INTO inventories.inventory_sites VALUES ('PRIVATE_ORDER','P0673822','KEEP','個別発注品',default,default,'100001-P0673822','100001-P0673822');
INSERT INTO inventories.inventory_sites VALUES ('OTHER_KEEP','P0673822','KEEP','その他確保用',default,default,'100001-P0673822','100001-P0673822');

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
INSERT INTO inventories.suppliers VALUES ('E00102','ACTIVE',10,1,15,'P0673822','豊臣秀吉','WEEKLY','WED',5,null,default,default,'100005-P0673822','100005-P0673822');

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

## サンプルデータ登録SQL(transactions・項目毎)

``` SQL
-- *** ORDERINGS ***
-- ORDERING-1
UPDATE business_date SET present_date = '2024-02-26' WHERE business_date_type = 'BASE';
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100101-P0673822','100101-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000001','AAA002001E',5,0,0,0,default,default,default,default,default,default,'100101-P0673822','100101-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000001','AAA002002S',7,0,0,0,10500,default,default,default,default,default,'100101-P0673822','100101-P0673822');

-- ORDERING-1(CHANGE ARRIVAL DATE)
UPDATE business_date SET present_date = '2024-02-28' WHERE business_date_type = 'BASE';
INSERT INTO inventories.order_arrival_change_instructions VALUES (default,default,default,'P0673822','仕入先都合','PO-0000001','AAA002001E','2024-03-15',default,default,'100102-P0673822','100102-P0673822');

-- ORDERING-1(CANCEL)
UPDATE business_date SET present_date = '2024-03-01' WHERE business_date_type = 'BASE';
INSERT INTO inventories.order_cancel_instructions VALUES (default,default,default,'P0673822','オーダーミス','PO-0000001','AAA002002S',3,default,default,'100103-P0673822','100103-P0673822');

-- ORDERING-2
UPDATE business_date SET present_date = '2024-03-05' WHERE business_date_type = 'BASE';
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100104-P0673822','100104-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000002','AAA002001E',3,0,0,0,5800,default,default,default,default,default,'100104-P0673822','100104-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000002','AAA002025S',4,0,0,0,default,default,default,default,default,default,'100104-P0673822','100104-P0673822');

-- ORDERING-3
UPDATE business_date SET present_date = '2024-03-15' WHERE business_date_type = 'BASE';
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100105-P0673822','100105-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000003','AAA002001E',2,0,0,0,default,default,default,default,default,default,'100105-P0673822','100105-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000003','AAA002002S',2,0,0,0,default,default,default,default,default,default,'100105-P0673822','100105-P0673822');

-- ORDERING-4
UPDATE business_date SET present_date = '2024-03-25' WHERE business_date_type = 'BASE';
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100106-P0673822','100106-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000004','AAA002001E',3,0,0,0,default,default,default,default,default,default,'100106-P0673822','100106-P0673822');

-- ORDERING-5
UPDATE business_date SET present_date = '2024-03-27' WHERE business_date_type = 'BASE';
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100107-P0673822','100107-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000005','AAA002002S',4,0,0,0,default,default,default,default,default,default,'100107-P0673822','100107-P0673822');

-- ORDERING-6
UPDATE business_date SET present_date = '2024-04-03' WHERE business_date_type = 'BASE';
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00102',NULL,default,default,'100108-P0673822','100108-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000006','BBB054792F',10,0,0,0,default,default,default,default,default,default,'100108-P0673822','100108-P0673822');


-- *** WAREHOUSINGS ***
-- WAREHOUSING-1(ORDERING-1:PART-OF)
UPDATE business_date SET present_date = '2024-03-05' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100201-P0673822','100201-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000001','PO-0000001','AAA002002S',4,0,default,default,'ON_INSPECT',default,default,default,'100201-P0673822','100201-P0673822');

-- WAREHOUSING-2(ORDERING-1:COMPLETE/ORDERING-2:PART-OF)
UPDATE business_date SET present_date = '2024-03-15' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100202-P0673822','100202-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000002','PO-0000001','AAA002001E',5,0,5000,default,'ON_INSPECT',default,default,default,'100202-P0673822','100202-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000002','PO-0000002','AAA002001E',1,0,default,default,'ON_INSPECT',default,default,default,'100202-P0673822','100202-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000002','PO-0000002','AAA002025S',4,0,default,default,'ON_INSPECT',default,default,default,'100202-P0673822','100202-P0673822');

-- WAREHOUSING-3(ORDERING-2:COMPLETE) *INPUT PAST DATA AFTER CUT OFF DATE AND BEFORE AMOUNT COMFIRMED DATE.
UPDATE business_date SET present_date = '2024-03-22' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousings VALUES (default,'2024-03-20',default,'P0673822','E00101',default,default,default,'登録忘れ',default,default,'100203-P0673822','100203-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000003','PO-0000002','AAA002001E',2,0,5500,default,'ON_INSPECT',default,default,default,'100203-P0673822','100203-P0673822');

-- WAREHOUSING-4(ORDERING-3:PART-OF) *ANOTHER PAYMENT BECAUSE AFTER CUT OFF DATE.
UPDATE business_date SET present_date = '2024-03-23' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100205-P0673822','100205-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000004','PO-0000003','AAA002002S',2,0,12000,default,'ON_INSPECT',default,default,default,'100205-P0673822','100205-P0673822');

-- PAYMENT-1(AMOUNT COMFIRMED)
UPDATE business_date SET present_date = '2024-03-25' WHERE business_date_type = 'BASE';
INSERT INTO inventories.payment_confirm_instructions VALUES (default,default,default,'P0673822',NULL,'PM-0000001',default,default,'100204-P0673822','100204-P0673822');

-- WAREHOUSING-5(ORDERING-3:COMPLETE)
UPDATE business_date SET present_date = '2024-03-25' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100206-P0673822','100206-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000005','PO-0000003','AAA002001E',2,0,default,default,'ON_INSPECT',default,default,default,'100206-P0673822','100206-P0673822');

-- WAREHOUSING-6(ORDERING-4:COMPLETE/ORDERING-5:COMPLETE)
UPDATE business_date SET present_date = '2024-04-04' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100207-P0673822','100207-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000006','PO-0000004','AAA002001E',3,0,5700,default,'ON_INSPECT',default,default,default,'100207-P0673822','100207-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000006','PO-0000005','AAA002002S',4,0,default,default,'ON_INSPECT',default,default,default,'100207-P0673822','100207-P0673822');

-- WAREHOUSING-7(ORDERING-6:PART-OF)
UPDATE business_date SET present_date = '2024-04-08' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00102',default,default,default,NULL,default,default,'100208-P0673822','100208-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000007','PO-0000006','BBB054792F',6,0,default,default,'ON_INSPECT',default,default,default,'100208-P0673822','100208-P0673822');

-- PAYABLE-CORRECT *REDUCE AMOUNT.
UPDATE business_date SET present_date = '2024-04-10' WHERE business_date_type = 'BASE';
INSERT INTO inventories.correct_payable_instructions VALUES (default,default,default,'P0673822','瑕疵理由による支払減額','E00101',-20000,default,default,default,default,default,'100209-P0673822','100209-P0673822');

-- PAYMENT-3(AMOUNT COMFIRMED)
UPDATE business_date SET present_date = '2024-04-12' WHERE business_date_type = 'BASE';
INSERT INTO inventories.payment_confirm_instructions VALUES (default,default,default,'P0673822',NULL,'PM-0000003',default,default,'100210-P0673822','100210-P0673822');

-- PAYMENT-1(AMOUNT COMPLETE)
UPDATE business_date SET present_date = '2024-04-20' WHERE business_date_type = 'BASE';
INSERT INTO inventories.payment_instructions VALUES (default,default,default,'P0673822',NULL,'PM-0000001',default,default,'100211-P0673822','100211-P0673822');


-- *** INVENTORIES ***
-- MOVE-FOR-INSPECTION-1(WAREHOUSING-1)
UPDATE business_date SET present_date = '2024-03-06' WHERE business_date_type = 'BASE';
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','AAA002002S',4,default,default,'100301-P0673822','100301-P0673822');

-- MOVE-FOR-INSPECTION-2(WAREHOUSING-2/WAREHOUSING-3) *DEFECTIVE PRODUCT.
UPDATE business_date SET present_date = '2024-03-22' WHERE business_date_type = 'BASE';
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','AAA002001E',7,default,default,'100302-P0673822','100302-P0673822');
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品不良品','ON_INSPECT','DEFECTIVE_INSPECTION','AAA002001E',1,default,default,'100303-P0673822','100303-P0673822');
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','AAA002025S',4,default,default,'100304-P0673822','100304-P0673822');

-- MOVE-FOR-INSPECTION-3(WAREHOUSING-4)
UPDATE business_date SET present_date = '2024-03-24' WHERE business_date_type = 'BASE';
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','AAA002002S',2,default,default,'100305-P0673822','100305-P0673822');

-- WAREHOUSING-2(RETURN) *DEFECTIVE PRODUCT.
-- INVENTORY-CORRECT *REDUCE AMOUNT.
UPDATE business_date SET present_date = '2024-03-25' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousing_return_instructions VALUES (default,default,default,'P0673822','不良品の返品','WH-0000002','PO-0000002','AAA002001E','DEFECTIVE_INSPECTION',1,3000,default,default,'PM-0000001',default,default,'100306-P0673822','100306-P0673822');
INSERT INTO inventories.correct_inventory_instructions VALUES (default,default,default,'P0673822','当社瑕疵分損失計上','DEFECTIVE_INSPECTION','AAA002001E',0,-2000,default,default,'100307-P0673822','100307-P0673822');

-- MOVE-FOR-INSPECTION-4(WAREHOUSING-5)
UPDATE business_date SET present_date = '2024-03-26' WHERE business_date_type = 'BASE';
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','AAA002001E',2,default,default,'100308-P0673822','100308-P0673822');

-- MOVE-FOR-INSPECTION-5(WAREHOUSING-6)
UPDATE business_date SET present_date = '2024-04-05' WHERE business_date_type = 'BASE';
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','AAA002001E',3,default,default,'100309-P0673822','100309-P0673822');
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','AAA002002S',4,default,default,'100310-P0673822','100310-P0673822');

-- INVENTORY-CORRECT *INCREASE AMOUNT.
UPDATE business_date SET present_date = '2024-04-06' WHERE business_date_type = 'BASE';
INSERT INTO inventories.correct_inventory_instructions VALUES (default,default,default,'P0673822','譲与による入荷','USUALLY','AAA002001E',1, 5100,default,default,'100311-P0673822','100311-P0673822');

-- MOVE-FOR-INSPECTION-6(WAREHOUSING-7) *DEFECTIVE PRODUCT.
UPDATE business_date SET present_date = '2024-04-09' WHERE business_date_type = 'BASE';
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','BBB054792F',4,default,default,'100312-P0673822','100312-P0673822');
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品不良品','ON_INSPECT','DEFECTIVE_INSPECTION','BBB054792F',2,default,default,'100313-P0673822','100313-P0673822');

-- WAREHOUSING-7(RETURN) *DEFECTIVE PRODUCT.
UPDATE business_date SET present_date = '2024-04-13' WHERE business_date_type = 'BASE';
INSERT INTO inventories.warehousing_return_instructions VALUES (default,default,default,'P0673822','不良品の返品','WH-0000007','PO-0000006','BBB054792F','DEFECTIVE_INSPECTION',2,default,default,default,'PM-0000003',default,default,'100314-P0673822','100314-P0673822');


-- *** RECEIVINGS ***
-- RECEIVING-1
UPDATE business_date SET present_date = '2024-03-06' WHERE business_date_type = 'BASE';
INSERT INTO inventories.receivings VALUES (default,default,default,'P0673822','S00201',default,NULL,default,default,'100401-P0673822','100401-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000001','AAA002002S',6,0,0,0,15000,default,default,default,default,'100401-P0673822','100401-P0673822');

-- RECEIVING-1(CANCEL)
UPDATE business_date SET present_date = '2024-03-07' WHERE business_date_type = 'BASE';
INSERT INTO inventories.receiving_cancel_instructions VALUES (default,default,default,'P0673822','お客様都合','RO-0000001','AAA002002S',2,default,default,'100402-P0673822','100402-P0673822');

-- RECEIVING-2
UPDATE business_date SET present_date = '2024-03-25' WHERE business_date_type = 'BASE';
INSERT INTO inventories.receivings VALUES (default,default,default,'P0673822','S00201',default,NULL,default,default,'100403-P0673822','100403-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000002','AAA002001E',3,0,0,0,default,default,default,default,default,'100403-P0673822','100403-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000002','AAA002002S',2,0,0,0,default,default,default,default,default,'100403-P0673822','100403-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000002','AAA002025S',4,0,0,0,default,default,default,default,default,'100403-P0673822','100403-P0673822');

-- RECEIVING-3
UPDATE business_date SET present_date = '2024-03-31' WHERE business_date_type = 'BASE';
INSERT INTO inventories.receivings VALUES (default,default,default,'P0673822','S00201',default,NULL,default,default,'100404-P0673822','100404-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000003','AAA002001E',2,0,0,0,default,default,default,default,default,'100404-P0673822','100404-P0673822');

-- RECEIVING-4(HIGH PRIORITY)
UPDATE business_date SET present_date = '2024-04-01' WHERE business_date_type = 'BASE';
INSERT INTO inventories.receivings VALUES (default,default,default,'P0673822','S00201',10,'優先出荷対象',default,default,'100405-P0673822','100405-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000004','AAA002001E',2,0,0,0,default,default,default,default,default,'100405-P0673822','100405-P0673822');

-- RECEIVING-5
UPDATE business_date SET present_date = '2024-04-02' WHERE business_date_type = 'BASE';
INSERT INTO inventories.receivings VALUES (default,default,default,'P0673822','E00101',default,NULL,default,default,'100406-P0673822','100406-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000005','AAA002001E',1,0,0,0,default,default,default,default,default,'100406-P0673822','100406-P0673822');

-- RECEIVING-6
UPDATE business_date SET present_date = '2024-04-03' WHERE business_date_type = 'BASE';
INSERT INTO inventories.receivings VALUES (default,default,default,'P0673822','E00101',default,NULL,default,default,'100407-P0673822','100407-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000006','AAA002002S',2,0,0,0,default,default,default,default,default,'100407-P0673822','100407-P0673822');

-- RECEIVING-7
UPDATE business_date SET present_date = '2024-04-03' WHERE business_date_type = 'BASE';
INSERT INTO inventories.receivings VALUES (default,default,default,'P0673822','S00201',default,NULL,default,default,'100408-P0673822','100408-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000007','AAA002001E',4,0,0,0,default,default,default,default,default,'100408-P0673822','100408-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000007','BBB054792F',4,0,0,0,default,default,default,default,default,'100408-P0673822','100408-P0673822');

-- *** SHIPPINGS ***
-- SHIPPING-1(RECEIVING-1:PART-OF)
UPDATE business_date SET present_date = '2024-03-10' WHERE business_date_type = 'BASE';
INSERT INTO inventories.shippings VALUES (default,default,default,'P0673822','S00201',default,default,default,NULL,default,default,'100501-P0673822','100501-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000001','RO-0000001','AAA002002S',3,0,default,default,default,'USUALLY',default,default,default,'100501-P0673822','100501-P0673822');

-- SHIPPING-2(RECEIVING-1:COMPLETE/RECEIVING-2:COMPLETE)
UPDATE business_date SET present_date = '2024-03-28' WHERE business_date_type = 'BASE';
INSERT INTO inventories.shippings VALUES (default,default,default,'P0673822','S00201',default,default,default,'納期遅れのため値引き',default,default,'100502-P0673822','100502-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000002','RO-0000001','AAA002002S',1,0,13500,default,default,'USUALLY',default,default,default,'100502-P0673822','100502-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000002','RO-0000002','AAA002001E',3,0,default,default,default,'USUALLY',default,default,default,'100502-P0673822','100502-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000002','RO-0000002','AAA002002S',2,0,default,default,default,'USUALLY',default,default,default,'100502-P0673822','100502-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000002','RO-0000002','AAA002025S',4,0,default,default,default,'USUALLY',default,default,default,'100502-P0673822','100502-P0673822');

-- SHIPPING-3(RECEIVING-4:COMPLETE/HIGH PRIORITY)
UPDATE business_date SET present_date = '2024-04-01' WHERE business_date_type = 'BASE';
INSERT INTO inventories.shippings VALUES (default,default,default,'P0673822','S00201',default,default,default,NULL,default,default,'100503-P0673822','100503-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000003','RO-0000004','AAA002001E',2,0,default,default,default,'USUALLY',default,default,default,'100503-P0673822','100503-P0673822');

-- DEPOSIT-1(ADVANCED PAYMENT)
UPDATE business_date SET present_date = '2024-04-02' WHERE business_date_type = 'BASE';
INSERT INTO inventories.deposits VALUES (default,default,default,'P0673822','S00201',50000,0,0,default,default,default,'100504-P0673822','100504-P0673822');

-- SHIPPING-4(RECEIVING-3:COMPLETE)
UPDATE business_date SET present_date = '2024-04-03' WHERE business_date_type = 'BASE';
INSERT INTO inventories.shippings VALUES (default,default,default,'P0673822','S00201',default,default,default,NULL,default,default,'100505-P0673822','100505-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000004','RO-0000003','AAA002001E',2,0,default,default,default,'USUALLY',default,default,default,'100505-P0673822','100505-P0673822');

-- SHIPPING-5(RECEIVING-5:COMPLETE)
UPDATE business_date SET present_date = '2024-04-04' WHERE business_date_type = 'BASE';
INSERT INTO inventories.shippings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100506-P0673822','100506-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000005','RO-0000005','AAA002001E',1,0,default,default,default,'USUALLY',default,default,default,'100506-P0673822','100506-P0673822');

-- SHIPPING-6(RECEIVING-6:COMPLETE)
UPDATE business_date SET present_date = '2024-04-05' WHERE business_date_type = 'BASE';
INSERT INTO inventories.shippings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100507-P0673822','100507-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000006','RO-0000006','AAA002002S',2,0,default,default,default,'USUALLY',default,default,default,'100507-P0673822','100507-P0673822');

-- BILLS-1(AMOUNT COMFIRMED)
-- BILLS-3(AMOUNT COMFIRMED)
UPDATE business_date SET present_date = '2024-04-06' WHERE business_date_type = 'BASE';
INSERT INTO inventories.billing_confirm_instructions VALUES (default,default,default,'P0673822',NULL,'BL-0000001',default,default,'100508-P0673822','100508-P0673822');
INSERT INTO inventories.billing_confirm_instructions VALUES (default,default,default,'P0673822',NULL,'BL-0000003',default,default,'100508-P0673822','100508-P0673822');

-- SHIPPING-2(RETURN) *INIT DEFECTIVE PRODUCT.
UPDATE business_date SET present_date = '2024-04-08' WHERE business_date_type = 'BASE';
INSERT INTO inventories.shipping_return_instructions VALUES (default,default,default,'P0673822','お客様都合','SP-0000002','RO-0000002','AAA002025S','ON_INSPECT',2,default,default,default,default,default,default,default,'100509-P0673822','100509-P0673822');

-- SHIPPING-7(RECEIVING-7:COMPLETE)
UPDATE business_date SET present_date = '2024-04-10' WHERE business_date_type = 'BASE';
INSERT INTO inventories.shippings VALUES (default,default,default,'P0673822','S00201',default,default,default,NULL,default,default,'100510-P0673822','100510-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000007','RO-0000007','AAA002001E',4,0,default,default,default,'USUALLY',default,default,default,'100510-P0673822','100510-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000007','RO-0000007','BBB054792F',4,0,default,default,default,'USUALLY',default,default,default,'100510-P0673822','100510-P0673822');

-- DEPOSIT-2(APPLY FOR BILL-1)
UPDATE business_date SET present_date = '2024-04-15' WHERE business_date_type = 'BASE';
INSERT INTO inventories.deposits VALUES (default,default,default,'P0673822','S00201',100000,0,0,default,default,default,'100511-P0673822','100511-P0673822');

-- RECEIVABLE-CORRECT *LATE PAYMENT FEE.
UPDATE business_date SET present_date = '2024-04-18' WHERE business_date_type = 'BASE';
INSERT INTO inventories.correct_receivable_instructions VALUES (default,default,default,'P0673822','遅延損害金','E00101',300000,default,default,default,default,default,'100512-P0673822','100512-P0673822');

-- BILLS-2(AMOUNT COMFIRMED)
UPDATE business_date SET present_date = '2024-05-10' WHERE business_date_type = 'BASE';
INSERT INTO inventories.billing_confirm_instructions VALUES (default,default,default,'P0673822',NULL,'BL-0000002',default,default,'100513-P0673822','100513-P0673822');
```

## サンプルデータ登録SQL(transactions・日付順)

``` SQL
UPDATE business_date SET present_date = '2024-02-26' WHERE business_date_type = 'BASE';
-- ORDERING-1
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100101-P0673822','100101-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000001','AAA002001E',5,0,0,0,default,default,default,default,default,default,'100101-P0673822','100101-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000001','AAA002002S',7,0,0,0,10500,default,default,default,default,default,'100101-P0673822','100101-P0673822');

UPDATE business_date SET present_date = '2024-02-28' WHERE business_date_type = 'BASE';
-- ORDERING-1(CHANGE ARRIVAL DATE)
INSERT INTO inventories.order_arrival_change_instructions VALUES (default,default,default,'P0673822','仕入先都合','PO-0000001','AAA002001E','2024-03-15',default,default,'100102-P0673822','100102-P0673822');

UPDATE business_date SET present_date = '2024-03-01' WHERE business_date_type = 'BASE';
-- ORDERING-1(CANCEL)
INSERT INTO inventories.order_cancel_instructions VALUES (default,default,default,'P0673822','オーダーミス','PO-0000001','AAA002002S',3,default,default,'100103-P0673822','100103-P0673822');

UPDATE business_date SET present_date = '2024-03-05' WHERE business_date_type = 'BASE';
-- ORDERING-2
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100104-P0673822','100104-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000002','AAA002001E',3,0,0,0,5800,default,default,default,default,default,'100104-P0673822','100104-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000002','AAA002025S',4,0,0,0,default,default,default,default,default,default,'100104-P0673822','100104-P0673822');
-- WAREHOUSING-1(ORDERING-1:PART-OF)
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100201-P0673822','100201-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000001','PO-0000001','AAA002002S',4,0,default,default,'ON_INSPECT',default,default,default,'100201-P0673822','100201-P0673822');

UPDATE business_date SET present_date = '2024-03-06' WHERE business_date_type = 'BASE';
-- MOVE-FOR-INSPECTION-1(WAREHOUSING-1)
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','AAA002002S',4,default,default,'100301-P0673822','100301-P0673822');
-- RECEIVING-1
INSERT INTO inventories.receivings VALUES (default,default,default,'P0673822','S00201',default,NULL,default,default,'100401-P0673822','100401-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000001','AAA002002S',6,0,0,0,15000,default,default,default,default,'100401-P0673822','100401-P0673822');

UPDATE business_date SET present_date = '2024-03-07' WHERE business_date_type = 'BASE';
-- RECEIVING-1(CANCEL)
INSERT INTO inventories.receiving_cancel_instructions VALUES (default,default,default,'P0673822','お客様都合','RO-0000001','AAA002002S',2,default,default,'100402-P0673822','100402-P0673822');

UPDATE business_date SET present_date = '2024-03-10' WHERE business_date_type = 'BASE';
-- SHIPPING-1(RECEIVING-1:PART-OF)
INSERT INTO inventories.shippings VALUES (default,default,default,'P0673822','S00201',default,default,default,NULL,default,default,'100501-P0673822','100501-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000001','RO-0000001','AAA002002S',3,0,default,default,default,'USUALLY',default,default,default,'100501-P0673822','100501-P0673822');

UPDATE business_date SET present_date = '2024-03-15' WHERE business_date_type = 'BASE';
-- ORDERING-3
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100105-P0673822','100105-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000003','AAA002001E',2,0,0,0,default,default,default,default,default,default,'100105-P0673822','100105-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000003','AAA002002S',2,0,0,0,default,default,default,default,default,default,'100105-P0673822','100105-P0673822');
-- WAREHOUSING-2(ORDERING-1:COMPLETE/ORDERING-2:PART-OF)
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100202-P0673822','100202-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000002','PO-0000001','AAA002001E',5,0,5000,default,'ON_INSPECT',default,default,default,'100202-P0673822','100202-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000002','PO-0000002','AAA002001E',1,0,default,default,'ON_INSPECT',default,default,default,'100202-P0673822','100202-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000002','PO-0000002','AAA002025S',4,0,default,default,'ON_INSPECT',default,default,default,'100202-P0673822','100202-P0673822');

UPDATE business_date SET present_date = '2024-03-22' WHERE business_date_type = 'BASE';
-- WAREHOUSING-3(ORDERING-2:COMPLETE) *INPUT PAST DATA AFTER CUT OFF DATE AND BEFORE AMOUNT COMFIRMED DATE.
INSERT INTO inventories.warehousings VALUES (default,'2024-03-20',default,'P0673822','E00101',default,default,default,'登録忘れ',default,default,'100203-P0673822','100203-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000003','PO-0000002','AAA002001E',2,0,5500,default,'ON_INSPECT',default,default,default,'100203-P0673822','100203-P0673822');
-- MOVE-FOR-INSPECTION-2(WAREHOUSING-2/WAREHOUSING-3)*DEFECTIVE PRODUCT.
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','AAA002001E',7,default,default,'100302-P0673822','100302-P0673822');
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品不良品','ON_INSPECT','DEFECTIVE_INSPECTION','AAA002001E',1,default,default,'100303-P0673822','100303-P0673822');
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','AAA002025S',4,default,default,'100304-P0673822','100304-P0673822');

UPDATE business_date SET present_date = '2024-03-23' WHERE business_date_type = 'BASE';
-- WAREHOUSING-4(ORDERING-3:PART-OF) *ANOTHER PAYMENT BECAUSE AFTER CUT OFF DATE.
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100205-P0673822','100205-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000004','PO-0000003','AAA002002S',2,0,12000,default,'ON_INSPECT',default,default,default,'100205-P0673822','100205-P0673822');

UPDATE business_date SET present_date = '2024-03-24' WHERE business_date_type = 'BASE';
-- MOVE-FOR-INSPECTION-3(WAREHOUSING-4)
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','AAA002002S',2,default,default,'100305-P0673822','100305-P0673822');

UPDATE business_date SET present_date = '2024-03-25' WHERE business_date_type = 'BASE';
-- ORDERING-4
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100106-P0673822','100106-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000004','AAA002001E',3,0,0,0,default,default,default,default,default,default,'100106-P0673822','100106-P0673822');
-- PAYMENT-1(AMOUNT COMFIRMED)
INSERT INTO inventories.payment_confirm_instructions VALUES (default,default,default,'P0673822',NULL,'PM-0000001',default,default,'100204-P0673822','100204-P0673822');
-- WAREHOUSING-5(ORDERING-3:COMPLETE)
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100206-P0673822','100206-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000005','PO-0000003','AAA002001E',2,0,default,default,'ON_INSPECT',default,default,default,'100206-P0673822','100206-P0673822');
-- WAREHOUSING-2(RETURN) *DEFECTIVE PRODUCT.
-- INVENTORY-CORRECT*REDUCE AMOUNT.
INSERT INTO inventories.warehousing_return_instructions VALUES (default,default,default,'P0673822','不良品の返品','WH-0000002','PO-0000002','AAA002001E','DEFECTIVE_INSPECTION',1,3000,default,default,'PM-0000001',default,default,'100306-P0673822','100306-P0673822');
INSERT INTO inventories.correct_inventory_instructions VALUES (default,default,default,'P0673822','当社瑕疵分損失計上','DEFECTIVE_INSPECTION','AAA002001E',0,-2000,default,default,'100307-P0673822','100307-P0673822');
-- RECEIVING-2
INSERT INTO inventories.receivings VALUES (default,default,default,'P0673822','S00201',default,NULL,default,default,'100403-P0673822','100403-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000002','AAA002001E',3,0,0,0,default,default,default,default,default,'100403-P0673822','100403-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000002','AAA002002S',2,0,0,0,default,default,default,default,default,'100403-P0673822','100403-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000002','AAA002025S',4,0,0,0,default,default,default,default,default,'100403-P0673822','100403-P0673822');

UPDATE business_date SET present_date = '2024-03-26' WHERE business_date_type = 'BASE';
-- MOVE-FOR-INSPECTION-4(WAREHOUSING-5)
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','AAA002001E',2,default,default,'100308-P0673822','100308-P0673822');

UPDATE business_date SET present_date = '2024-03-27' WHERE business_date_type = 'BASE';
-- ORDERING-5
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00101',NULL,default,default,'100107-P0673822','100107-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000005','AAA002002S',4,0,0,0,default,default,default,default,default,default,'100107-P0673822','100107-P0673822');

UPDATE business_date SET present_date = '2024-03-28' WHERE business_date_type = 'BASE';
-- SHIPPING-2(RECEIVING-1:COMPLETE/RECEIVING-2:COMPLETE)
INSERT INTO inventories.shippings VALUES (default,default,default,'P0673822','S00201',default,default,default,'納期遅れのため値引き',default,default,'100502-P0673822','100502-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000002','RO-0000001','AAA002002S',1,0,13500,default,default,'USUALLY',default,default,default,'100502-P0673822','100502-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000002','RO-0000002','AAA002001E',3,0,default,default,default,'USUALLY',default,default,default,'100502-P0673822','100502-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000002','RO-0000002','AAA002002S',2,0,default,default,default,'USUALLY',default,default,default,'100502-P0673822','100502-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000002','RO-0000002','AAA002025S',4,0,default,default,default,'USUALLY',default,default,default,'100502-P0673822','100502-P0673822');

UPDATE business_date SET present_date = '2024-03-31' WHERE business_date_type = 'BASE';
-- RECEIVING-3
INSERT INTO inventories.receivings VALUES (default,default,default,'P0673822','S00201',default,NULL,default,default,'100404-P0673822','100404-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000003','AAA002001E',2,0,0,0,default,default,default,default,default,'100404-P0673822','100404-P0673822');

UPDATE business_date SET present_date = '2024-04-01' WHERE business_date_type = 'BASE';
-- RECEIVING-4(HIGH PRIORITY)
INSERT INTO inventories.receivings VALUES (default,default,default,'P0673822','S00201',10,'優先出荷対象',default,default,'100405-P0673822','100405-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000004','AAA002001E',2,0,0,0,default,default,default,default,default,'100405-P0673822','100405-P0673822');
-- SHIPPING-3(RECEIVING-4:COMPLETE/HIGH PRIORITY)
INSERT INTO inventories.shippings VALUES (default,default,default,'P0673822','S00201',default,default,default,NULL,default,default,'100503-P0673822','100503-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000003','RO-0000004','AAA002001E',2,0,default,default,default,'USUALLY',default,default,default,'100503-P0673822','100503-P0673822');

UPDATE business_date SET present_date = '2024-04-02' WHERE business_date_type = 'BASE';
-- RECEIVING-5
INSERT INTO inventories.receivings VALUES (default,default,default,'P0673822','E00101',default,NULL,default,default,'100406-P0673822','100406-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000005','AAA002001E',1,0,0,0,default,default,default,default,default,'100406-P0673822','100406-P0673822');
-- DEPOSIT-1(ADVANCED PAYMENT)
INSERT INTO inventories.deposits VALUES (default,default,default,'P0673822','S00201',50000,0,0,default,default,default,'100504-P0673822','100504-P0673822');

UPDATE business_date SET present_date = '2024-04-03' WHERE business_date_type = 'BASE';
-- ORDERING-6
INSERT INTO inventories.orderings VALUES (default,default,default,'P0673822','E00102',NULL,default,default,'100108-P0673822','100108-P0673822');
INSERT INTO inventories.ordering_details VALUES ('PO-0000006','BBB054792F',10,0,0,0,default,default,default,default,default,default,'100108-P0673822','100108-P0673822');
-- RECEIVING-6
INSERT INTO inventories.receivings VALUES (default,default,default,'P0673822','E00101',default,NULL,default,default,'100407-P0673822','100407-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000006','AAA002002S',2,0,0,0,default,default,default,default,default,'100407-P0673822','100407-P0673822');
-- RECEIVING-7
INSERT INTO inventories.receivings VALUES (default,default,default,'P0673822','S00201',default,NULL,default,default,'100408-P0673822','100408-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000007','AAA002001E',4,0,0,0,default,default,default,default,default,'100408-P0673822','100408-P0673822');
INSERT INTO inventories.receiving_details VALUES ('RO-0000007','BBB054792F',4,0,0,0,default,default,default,default,default,'100408-P0673822','100408-P0673822');
-- SHIPPING-4(RECEIVING-3:COMPLETE)
INSERT INTO inventories.shippings VALUES (default,default,default,'P0673822','S00201',default,default,default,NULL,default,default,'100505-P0673822','100505-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000004','RO-0000003','AAA002001E',2,0,default,default,default,'USUALLY',default,default,default,'100505-P0673822','100505-P0673822');

UPDATE business_date SET present_date = '2024-04-04' WHERE business_date_type = 'BASE';
-- WAREHOUSING-6(ORDERING-4:COMPLETE/ORDERING-5:COMPLETE)
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100207-P0673822','100207-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000006','PO-0000004','AAA002001E',3,0,5700,default,'ON_INSPECT',default,default,default,'100207-P0673822','100207-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000006','PO-0000005','AAA002002S',4,0,default,default,'ON_INSPECT',default,default,default,'100207-P0673822','100207-P0673822');
-- SHIPPING-5(RECEIVING-5:COMPLETE)
INSERT INTO inventories.shippings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100506-P0673822','100506-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000005','RO-0000005','AAA002001E',1,0,default,default,default,'USUALLY',default,default,default,'100506-P0673822','100506-P0673822');

UPDATE business_date SET present_date = '2024-04-05' WHERE business_date_type = 'BASE';
-- MOVE-FOR-INSPECTION-5(WAREHOUSING-6)
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','AAA002001E',3,default,default,'100309-P0673822','100309-P0673822');
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','AAA002002S',4,default,default,'100310-P0673822','100310-P0673822');
-- SHIPPING-6(RECEIVING-6:COMPLETE)
INSERT INTO inventories.shippings VALUES (default,default,default,'P0673822','E00101',default,default,default,NULL,default,default,'100507-P0673822','100507-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000006','RO-0000006','AAA002002S',2,0,default,default,default,'USUALLY',default,default,default,'100507-P0673822','100507-P0673822');

UPDATE business_date SET present_date = '2024-04-06' WHERE business_date_type = 'BASE';
-- INVENTORY-CORRECT *INCREASE AMOUNT.
INSERT INTO inventories.correct_inventory_instructions VALUES (default,default,default,'P0673822','譲与による入荷','USUALLY','AAA002001E',1, 5100,default,default,'100311-P0673822','100311-P0673822');
-- BILLS-1(AMOUNT COMFIRMED)
INSERT INTO inventories.billing_confirm_instructions VALUES (default,default,default,'P0673822',NULL,'BL-0000001',default,default,'100508-P0673822','100508-P0673822');
-- BILLS-3(AMOUNT COMFIRMED)
INSERT INTO inventories.billing_confirm_instructions VALUES (default,default,default,'P0673822',NULL,'BL-0000003',default,default,'100508-P0673822','100508-P0673822');

UPDATE business_date SET present_date = '2024-04-08' WHERE business_date_type = 'BASE';
-- WAREHOUSING-7(ORDERING-6:PART-OF)
INSERT INTO inventories.warehousings VALUES (default,default,default,'P0673822','E00102',default,default,default,NULL,default,default,'100208-P0673822','100208-P0673822');
INSERT INTO inventories.warehousing_details VALUES ('WH-0000007','PO-0000006','BBB054792F',6,0,default,default,'ON_INSPECT',default,default,default,'100208-P0673822','100208-P0673822');
-- SHIPPING-2(RETURN) *CUSTOMER REASON.
INSERT INTO inventories.shipping_return_instructions VALUES (default,default,default,'P0673822','お客様都合','SP-0000002','RO-0000002','AAA002025S','SHIPPING_RETURN',2,default,default,default,default,default,default,default,'100509-P0673822','100509-P0673822');

UPDATE business_date SET present_date = '2024-04-09' WHERE business_date_type = 'BASE';
-- MOVE-FOR-INSPECTION-6(WAREHOUSING-7) *DEFECTIVE PRODUCT.
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品完了','ON_INSPECT','USUALLY','BBB054792F',4,default,default,'100312-P0673822','100312-P0673822');
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','検品不良品','ON_INSPECT','DEFECTIVE_INSPECTION','BBB054792F',2,default,default,'100313-P0673822','100313-P0673822');

UPDATE business_date SET present_date = '2024-04-10' WHERE business_date_type = 'BASE';
-- PAYABLE-CORRECT *REDUCE AMOUNT.
INSERT INTO inventories.correct_payable_instructions VALUES (default,default,default,'P0673822','瑕疵理由による支払減額','E00101',-20000,default,default,default,default,default,'100209-P0673822','100209-P0673822');
-- SHIPPING-7(RECEIVING-7:COMPLETE)
INSERT INTO inventories.shippings VALUES (default,default,default,'P0673822','S00201',default,default,default,NULL,default,default,'100510-P0673822','100510-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000007','RO-0000007','AAA002001E',4,0,default,default,default,'USUALLY',default,default,default,'100510-P0673822','100510-P0673822');
INSERT INTO inventories.shipping_details VALUES ('SP-0000007','RO-0000007','BBB054792F',4,0,default,default,default,'USUALLY',default,default,default,'100510-P0673822','100510-P0673822');
-- MOVE-FOR-INSPECTION-7(SHIPPING-RETURN) *INSPECTION COMPLETE.
INSERT INTO inventories.moving_instructions VALUES (default,default,default,'P0673822','返品商品の検品保全完了','SHIPPING_RETURN','USUALLY','AAA002025S',2,default,default,'100312A-P0673822','100312A-P0673822');

UPDATE business_date SET present_date = '2024-04-12' WHERE business_date_type = 'BASE';
-- PAYMENT-3(AMOUNT COMFIRMED)
INSERT INTO inventories.payment_confirm_instructions VALUES (default,default,default,'P0673822',NULL,'PM-0000003',default,default,'100210-P0673822','100210-P0673822');

UPDATE business_date SET present_date = '2024-04-13' WHERE business_date_type = 'BASE';
-- WAREHOUSING-7(RETURN) *DEFECTIVE PRODUCT.
INSERT INTO inventories.warehousing_return_instructions VALUES (default,default,default,'P0673822','不良品の返品','WH-0000007','PO-0000006','BBB054792F','DEFECTIVE_INSPECTION',2,default,default,default,'PM-0000003',default,default,'100314-P0673822','100314-P0673822');

UPDATE business_date SET present_date = '2024-04-15' WHERE business_date_type = 'BASE';
-- DEPOSIT-2(APPLY FOR BILL-1)
INSERT INTO inventories.deposits VALUES (default,default,default,'P0673822','S00201',100000,0,0,default,default,default,'100511-P0673822','100511-P0673822');

UPDATE business_date SET present_date = '2024-04-18' WHERE business_date_type = 'BASE';
-- RECEIVABLE-CORRECT *LATE PAYMENT FEE.
INSERT INTO inventories.correct_receivable_instructions VALUES (default,default,default,'P0673822','遅延損害金','E00101',300000,default,default,default,default,default,'100512-P0673822','100512-P0673822');

UPDATE business_date SET present_date = '2024-04-20' WHERE business_date_type = 'BASE';
-- PAYMENT-1(AMOUNT COMPLETE)
INSERT INTO inventories.payment_instructions VALUES (default,default,default,'P0673822',NULL,'PM-0000001',default,default,'100211-P0673822','100211-P0673822');

UPDATE business_date SET present_date = '2024-05-10' WHERE business_date_type = 'BASE';
-- BILLS-2(AMOUNT COMFIRMED)
INSERT INTO inventories.billing_confirm_instructions VALUES (default,default,default,'P0673822',NULL,'BL-0000002',default,default,'100513-P0673822','100513-P0673822');
```
