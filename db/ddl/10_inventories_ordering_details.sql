-- is_master_table=false

-- 20.発注明細(ordering_details)

-- Create Table
DROP TABLE IF EXISTS inventories.ordering_details CASCADE;
CREATE TABLE inventories.ordering_details (
  ordering_id varchar(10) NOT NULL check (ordering_id ~* '^PO-[0-9]{7}$'),
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  ordering_quantity integer NOT NULL DEFAULT 0 check (ordering_quantity >= 0),
  warehousing_quantity integer NOT NULL DEFAULT 0 check (warehousing_quantity >= 0),
  cancel_quantity integer NOT NULL DEFAULT 0 check (cancel_quantity >= 0),
  remaining_quantity integer NOT NULL DEFAULT 0 check (remaining_quantity >= 0),
  unit_price numeric NOT NULL DEFAULT 0.00 check (unit_price >= 0),
  estimate_profit_rate numeric NOT NULL DEFAULT 0.00 check (estimate_profit_rate >= 0),
  standard_arrival_date date NOT NULL DEFAULT get_business_date(),
  estimate_arrival_date date NOT NULL DEFAULT get_business_date(),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.ordering_details IS '発注明細';

-- Set Column Comment
COMMENT ON COLUMN inventories.ordering_details.ordering_id IS '発注番号';
COMMENT ON COLUMN inventories.ordering_details.product_id IS '商品ID';
COMMENT ON COLUMN inventories.ordering_details.ordering_quantity IS '発注数量';
COMMENT ON COLUMN inventories.ordering_details.warehousing_quantity IS '入庫数量';
COMMENT ON COLUMN inventories.ordering_details.cancel_quantity IS 'キャンセル数量';
COMMENT ON COLUMN inventories.ordering_details.remaining_quantity IS '残数量';
COMMENT ON COLUMN inventories.ordering_details.unit_price IS '単価';
COMMENT ON COLUMN inventories.ordering_details.estimate_profit_rate IS '想定利益率';
COMMENT ON COLUMN inventories.ordering_details.standard_arrival_date IS '標準納期日付';
COMMENT ON COLUMN inventories.ordering_details.estimate_arrival_date IS '予定納期日付';
COMMENT ON COLUMN inventories.ordering_details.created_at IS '作成日時';
COMMENT ON COLUMN inventories.ordering_details.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.ordering_details.created_by IS '作成者';
COMMENT ON COLUMN inventories.ordering_details.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.ordering_details ADD PRIMARY KEY (
  ordering_id,
  product_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.ordering_details
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.ordering_details_audit();
CREATE OR REPLACE FUNCTION inventories.ordering_details_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.ordering_id || '-' || OLD.product_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.ordering_id || '-' || NEW.product_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.ordering_id || '-' || NEW.product_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.ordering_details
  FOR EACH ROW
EXECUTE PROCEDURE inventories.ordering_details_audit();
