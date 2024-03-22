-- is_master_table=true

-- 6.商品(products)

-- Create Table
DROP TABLE IF EXISTS inventories.products CASCADE;
CREATE TABLE inventories.products (
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  supplier_id varchar(6) NOT NULL check (LENGTH(supplier_id) = 6),
  product_code varchar(30) NOT NULL,
  product_name varchar(30) NOT NULL,
  dealing_status inventories.dealing_status NOT NULL DEFAULT 'READY',
  selling_price numeric NOT NULL DEFAULT 0.00 check (selling_price >= 0),
  cost_price numeric NOT NULL DEFAULT 0.00 check (cost_price >= 0),
  standard_profit_rate numeric check (standard_profit_rate >= 0),
  days_to_arrive integer check (days_to_arrive >= 1),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.products IS '商品';

-- Set Column Comment
COMMENT ON COLUMN inventories.products.product_id IS '商品ID';
COMMENT ON COLUMN inventories.products.supplier_id IS '仕入先ID';
COMMENT ON COLUMN inventories.products.product_code IS '仕入れ先商品コード';
COMMENT ON COLUMN inventories.products.product_name IS '商品名称';
COMMENT ON COLUMN inventories.products.dealing_status IS '取引状況';
COMMENT ON COLUMN inventories.products.selling_price IS '売価';
COMMENT ON COLUMN inventories.products.cost_price IS '原価';
COMMENT ON COLUMN inventories.products.standard_profit_rate IS '標準利益率';
COMMENT ON COLUMN inventories.products.days_to_arrive IS '標準入荷日数';
COMMENT ON COLUMN inventories.products.created_at IS '作成日時';
COMMENT ON COLUMN inventories.products.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.products.created_by IS '作成者';
COMMENT ON COLUMN inventories.products.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.products ADD PRIMARY KEY (
  product_id
);

-- Set Unique Constraint
ALTER TABLE inventories.products ADD CONSTRAINT products_unique_1 UNIQUE (
  supplier_id,
  product_code
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.products
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.products_audit();
CREATE OR REPLACE FUNCTION inventories.products_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.product_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.product_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.product_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.products
  FOR EACH ROW
EXECUTE PROCEDURE inventories.products_audit();
