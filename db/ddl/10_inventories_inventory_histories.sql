-- is_master_table=false

-- 12.在庫変動履歴(inventory_histories)

-- Create Table
DROP TABLE IF EXISTS inventories.inventory_histories CASCADE;
CREATE TABLE inventories.inventory_histories (
  inventory_no serial NOT NULL,
  business_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  site_id varchar(30) NOT NULL check (LENGTH(site_id) >= 1),
  variable_quantity integer NOT NULL,
  variable_amount numeric NOT NULL,
  inventory_type inventories.inventory_type NOT NULL,
  tranzaction_no serial NOT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.inventory_histories IS '在庫変動履歴';

-- Set Column Comment
COMMENT ON COLUMN inventories.inventory_histories.inventory_no IS '在庫変動No';
COMMENT ON COLUMN inventories.inventory_histories.business_date IS '業務取引日付';
COMMENT ON COLUMN inventories.inventory_histories.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.inventory_histories.product_id IS '商品ID';
COMMENT ON COLUMN inventories.inventory_histories.site_id IS '倉庫ID';
COMMENT ON COLUMN inventories.inventory_histories.variable_quantity IS '変動数量';
COMMENT ON COLUMN inventories.inventory_histories.variable_amount IS '変動金額';
COMMENT ON COLUMN inventories.inventory_histories.inventory_type IS '在庫変動種類';
COMMENT ON COLUMN inventories.inventory_histories.tranzaction_no IS '取引管理No';
COMMENT ON COLUMN inventories.inventory_histories.created_at IS '作成日時';
COMMENT ON COLUMN inventories.inventory_histories.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.inventory_histories.created_by IS '作成者';
COMMENT ON COLUMN inventories.inventory_histories.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.inventory_histories ADD PRIMARY KEY (
  inventory_no
);

-- create index
CREATE INDEX idx_inventory_histories_1 ON inventories.inventory_histories (
  product_id,
  business_date,
  operation_timestamp
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.inventory_histories
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.inventory_histories_audit();
CREATE OR REPLACE FUNCTION inventories.inventory_histories_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.inventory_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.inventory_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.inventory_no;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.inventory_histories
  FOR EACH ROW
EXECUTE PROCEDURE inventories.inventory_histories_audit();
