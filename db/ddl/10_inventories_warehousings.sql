-- is_master_table=false

-- 21.入荷(warehousings)

-- Create Table
DROP TABLE IF EXISTS inventories.warehousings CASCADE;
CREATE TABLE inventories.warehousings (
  warehousing_id varchar(10) NOT NULL check (warehousing_id ~* '^WH-[0-9]{7}$'),
  warehouse_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  supplier_id varchar(6) NOT NULL check (LENGTH(supplier_id) = 6),
  cut_off_date date NOT NULL,
  payment_limit_date date NOT NULL,
  payment_id varchar(10) NOT NULL check (payment_id ~* '^PM-[0-9]{7}$'),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.warehousings IS '入荷';

-- Set Column Comment
COMMENT ON COLUMN inventories.warehousings.warehousing_id IS '入荷番号';
COMMENT ON COLUMN inventories.warehousings.warehouse_date IS '入荷日付';
COMMENT ON COLUMN inventories.warehousings.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.warehousings.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.warehousings.supplier_id IS '仕入先ID';
COMMENT ON COLUMN inventories.warehousings.cut_off_date IS '締日付';
COMMENT ON COLUMN inventories.warehousings.payment_limit_date IS '支払期限日付';
COMMENT ON COLUMN inventories.warehousings.payment_id IS '支払番号';
COMMENT ON COLUMN inventories.warehousings.created_at IS '作成日時';
COMMENT ON COLUMN inventories.warehousings.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.warehousings.created_by IS '作成者';
COMMENT ON COLUMN inventories.warehousings.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.warehousings ADD PRIMARY KEY (
  warehousing_id
);

-- create index
CREATE INDEX idx_warehousings_1 ON inventories.warehousings (
  supplier_id,
  cut_off_date,
  payment_limit_date
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.warehousings
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.warehousings_audit();
CREATE OR REPLACE FUNCTION inventories.warehousings_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.warehousing_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.warehousing_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.warehousing_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.warehousings
  FOR EACH ROW
EXECUTE PROCEDURE inventories.warehousings_audit();
