-- is_master_table=false

-- 11.現在在庫サマリ(current_inventory_summaries)

-- Create Table
DROP TABLE IF EXISTS inventories.current_inventory_summaries CASCADE;
CREATE TABLE inventories.current_inventory_summaries (
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  present_quantity integer NOT NULL DEFAULT 0 check (present_quantity >= 0),
  present_amount numeric NOT NULL DEFAULT 0.00 check (present_amount >= 0),
  cost_price numeric check (cost_price >= 0),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.current_inventory_summaries IS '現在在庫サマリ';

-- Set Column Comment
COMMENT ON COLUMN inventories.current_inventory_summaries.product_id IS '商品ID';
COMMENT ON COLUMN inventories.current_inventory_summaries.present_quantity IS '在庫数量';
COMMENT ON COLUMN inventories.current_inventory_summaries.present_amount IS '在庫金額';
COMMENT ON COLUMN inventories.current_inventory_summaries.cost_price IS '原価';
COMMENT ON COLUMN inventories.current_inventory_summaries.created_at IS '作成日時';
COMMENT ON COLUMN inventories.current_inventory_summaries.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.current_inventory_summaries.created_by IS '作成者';
COMMENT ON COLUMN inventories.current_inventory_summaries.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.current_inventory_summaries ADD PRIMARY KEY (
  product_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.current_inventory_summaries
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.current_inventory_summaries_audit();
CREATE OR REPLACE FUNCTION inventories.current_inventory_summaries_audit() RETURNS TRIGGER AS $$
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
  ON inventories.current_inventory_summaries
  FOR EACH ROW
EXECUTE PROCEDURE inventories.current_inventory_summaries_audit();
