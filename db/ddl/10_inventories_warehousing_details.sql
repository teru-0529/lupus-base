-- is_master_table=false

-- 22.入荷明細(warehousing_details)

-- Create Table
DROP TABLE IF EXISTS inventories.warehousing_details CASCADE;
CREATE TABLE inventories.warehousing_details (
  warehousing_id varchar(10) NOT NULL check (warehousing_id ~* '^WH-[0-9]{7}$'),
  ordering_id varchar(10) NOT NULL check (ordering_id ~* '^PO-[0-9]{7}$'),
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  warehousing_quantity integer NOT NULL DEFAULT 0 check (warehousing_quantity >= 0),
  return_quantity integer NOT NULL DEFAULT 0 check (return_quantity >= 0),
  unit_price numeric NOT NULL check (unit_price >= 0),
  estimate_profit_rate numeric NOT NULL DEFAULT 0.00 check (estimate_profit_rate >= 0),
  site_id varchar(30) NOT NULL check (LENGTH(site_id) >= 1),
  warehousing_detail_no serial NOT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.warehousing_details IS '入荷明細';

-- Set Column Comment
COMMENT ON COLUMN inventories.warehousing_details.warehousing_id IS '入荷番号';
COMMENT ON COLUMN inventories.warehousing_details.ordering_id IS '発注番号';
COMMENT ON COLUMN inventories.warehousing_details.product_id IS '商品ID';
COMMENT ON COLUMN inventories.warehousing_details.warehousing_quantity IS '入庫数量';
COMMENT ON COLUMN inventories.warehousing_details.return_quantity IS '返品数量';
COMMENT ON COLUMN inventories.warehousing_details.unit_price IS '単価';
COMMENT ON COLUMN inventories.warehousing_details.estimate_profit_rate IS '想定利益率';
COMMENT ON COLUMN inventories.warehousing_details.site_id IS '倉庫ID';
COMMENT ON COLUMN inventories.warehousing_details.warehousing_detail_no IS '入荷明細No';
COMMENT ON COLUMN inventories.warehousing_details.created_at IS '作成日時';
COMMENT ON COLUMN inventories.warehousing_details.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.warehousing_details.created_by IS '作成者';
COMMENT ON COLUMN inventories.warehousing_details.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.warehousing_details ADD PRIMARY KEY (
  warehousing_id,
  ordering_id,
  product_id
);

-- Set Unique Constraint
ALTER TABLE inventories.warehousing_details ADD CONSTRAINT warehousing_details_unique_1 UNIQUE (
  warehousing_detail_no
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.warehousing_details
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.warehousing_details_audit();
CREATE OR REPLACE FUNCTION inventories.warehousing_details_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.warehousing_id || '-' || OLD.ordering_id || '-' || OLD.product_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.warehousing_id || '-' || NEW.ordering_id || '-' || NEW.product_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.warehousing_id || '-' || NEW.ordering_id || '-' || NEW.product_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.warehousing_details
  FOR EACH ROW
EXECUTE PROCEDURE inventories.warehousing_details_audit();
