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
