-- is_master_table=false

-- 35.受注明細(receiving_details)

-- Create Table
DROP TABLE IF EXISTS inventories.receiving_details CASCADE;
CREATE TABLE inventories.receiving_details (
  receiving_id varchar(10) NOT NULL check (receiving_id ~* '^RO-[0-9]{7}$'),
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  receiving_quantity integer NOT NULL DEFAULT 0 check (receiving_quantity >= 0),
  shipping_quantity integer NOT NULL DEFAULT 0 check (shipping_quantity >= 0),
  cancel_quantity integer NOT NULL DEFAULT 0 check (cancel_quantity >= 0),
  remaining_quantity integer NOT NULL DEFAULT 0 check (remaining_quantity >= 0),
  selling_price numeric NOT NULL check (selling_price >= 0),
  estimate_cost_price numeric NOT NULL DEFAULT 0.00 check (estimate_cost_price >= 0),
  estimate_profit_rate numeric NOT NULL DEFAULT 0.00 check (estimate_profit_rate >= 0),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.receiving_details IS '受注明細';

-- Set Column Comment
COMMENT ON COLUMN inventories.receiving_details.receiving_id IS '受注番号';
COMMENT ON COLUMN inventories.receiving_details.product_id IS '商品ID';
COMMENT ON COLUMN inventories.receiving_details.receiving_quantity IS '受注数量';
COMMENT ON COLUMN inventories.receiving_details.shipping_quantity IS '出庫数量';
COMMENT ON COLUMN inventories.receiving_details.cancel_quantity IS 'キャンセル数量';
COMMENT ON COLUMN inventories.receiving_details.remaining_quantity IS '残数量';
COMMENT ON COLUMN inventories.receiving_details.selling_price IS '売価';
COMMENT ON COLUMN inventories.receiving_details.estimate_cost_price IS '想定原価';
COMMENT ON COLUMN inventories.receiving_details.estimate_profit_rate IS '想定利益率';
COMMENT ON COLUMN inventories.receiving_details.created_at IS '作成日時';
COMMENT ON COLUMN inventories.receiving_details.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.receiving_details.created_by IS '作成者';
COMMENT ON COLUMN inventories.receiving_details.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.receiving_details ADD PRIMARY KEY (
  receiving_id,
  product_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.receiving_details
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.receiving_details_audit();
CREATE OR REPLACE FUNCTION inventories.receiving_details_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.receiving_id || '-' || OLD.product_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.receiving_id || '-' || NEW.product_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.receiving_id || '-' || NEW.product_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.receiving_details
  FOR EACH ROW
EXECUTE PROCEDURE inventories.receiving_details_audit();
