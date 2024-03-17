-- is_master_table=false

-- 37.出荷明細(shipping_details)

-- Create Table
DROP TABLE IF EXISTS inventories.shipping_details CASCADE;
CREATE TABLE inventories.shipping_details (
  sipping_id varchar(10) NOT NULL check (sipping_id ~* '^SP-[0-9]{7}$'),
  receiving_id varchar(10) NOT NULL check (receiving_id ~* '^RO-[0-9]{7}$'),
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  shipping_quantity integer NOT NULL DEFAULT 0 check (shipping_quantity >= 0),
  return_quantity integer NOT NULL DEFAULT 0 check (return_quantity >= 0),
  selling_price numeric NOT NULL check (selling_price >= 0),
  cost_price numeric NOT NULL DEFAULT 0.00 check (cost_price >= 0),
  profit_rate numeric NOT NULL DEFAULT 0.00 check (profit_rate >= 0),
  site_id varchar(30) NOT NULL check (LENGTH(site_id) >= 1),
  shipping_detail_no serial NOT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.shipping_details IS '出荷明細';

-- Set Column Comment
COMMENT ON COLUMN inventories.shipping_details.sipping_id IS '出荷番号';
COMMENT ON COLUMN inventories.shipping_details.receiving_id IS '受注番号';
COMMENT ON COLUMN inventories.shipping_details.product_id IS '商品ID';
COMMENT ON COLUMN inventories.shipping_details.shipping_quantity IS '出庫数量';
COMMENT ON COLUMN inventories.shipping_details.return_quantity IS '返品数量';
COMMENT ON COLUMN inventories.shipping_details.selling_price IS '売価';
COMMENT ON COLUMN inventories.shipping_details.cost_price IS '原価';
COMMENT ON COLUMN inventories.shipping_details.profit_rate IS '利益率';
COMMENT ON COLUMN inventories.shipping_details.site_id IS '倉庫ID';
COMMENT ON COLUMN inventories.shipping_details.shipping_detail_no IS '出荷明細No';
COMMENT ON COLUMN inventories.shipping_details.created_at IS '作成日時';
COMMENT ON COLUMN inventories.shipping_details.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.shipping_details.created_by IS '作成者';
COMMENT ON COLUMN inventories.shipping_details.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.shipping_details ADD PRIMARY KEY (
  sipping_id,
  receiving_id,
  product_id
);

-- Set Unique Constraint
ALTER TABLE inventories.shipping_details ADD CONSTRAINT shipping_details_unique_1 UNIQUE (
  shipping_detail_no
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.shipping_details
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.shipping_details_audit();
CREATE OR REPLACE FUNCTION inventories.shipping_details_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.sipping_id || '-' || OLD.receiving_id || '-' || OLD.product_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.sipping_id || '-' || NEW.receiving_id || '-' || NEW.product_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.sipping_id || '-' || NEW.receiving_id || '-' || NEW.product_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.shipping_details
  FOR EACH ROW
EXECUTE PROCEDURE inventories.shipping_details_audit();
