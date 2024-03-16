-- シーケンス
DROP SEQUENCE IF EXISTS inventories.billing_no_seed;
CREATE SEQUENCE inventories.billing_no_seed START 1;

DROP SEQUENCE IF EXISTS inventories.deposit_no_seed;
CREATE SEQUENCE inventories.deposit_no_seed START 1;

DROP SEQUENCE IF EXISTS inventories.receiving_no_seed;
CREATE SEQUENCE inventories.receiving_no_seed START 1;

DROP SEQUENCE IF EXISTS inventories.shipping_no_seed;
CREATE SEQUENCE inventories.shipping_no_seed START 1;
