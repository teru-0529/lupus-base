-- is_master_table=false

-- 36.出荷(shippings)

-- Create Table
DROP TABLE IF EXISTS inventories.shippings CASCADE;
CREATE TABLE inventories.shippings (
  sipping_id varchar(10) NOT NULL check (sipping_id ~* '^SP-[0-9]{7}$'),
  sipping_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  costomer_id varchar(6) NOT NULL check (LENGTH(costomer_id) = 6),
  cut_off_date date NOT NULL,
  deposit_limit_date date NOT NULL,
  billing_id varchar(10) NOT NULL check (billing_id ~* '^BL-[0-9]{7}$'),
  note text,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.shippings IS '出荷';

-- Set Column Comment
COMMENT ON COLUMN inventories.shippings.sipping_id IS '出荷番号';
COMMENT ON COLUMN inventories.shippings.sipping_date IS '出荷日付';
COMMENT ON COLUMN inventories.shippings.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.shippings.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.shippings.costomer_id IS '得意先ID';
COMMENT ON COLUMN inventories.shippings.cut_off_date IS '締日付';
COMMENT ON COLUMN inventories.shippings.deposit_limit_date IS '入金期限日付';
COMMENT ON COLUMN inventories.shippings.billing_id IS '請求番号';
COMMENT ON COLUMN inventories.shippings.note IS '備考';
COMMENT ON COLUMN inventories.shippings.created_at IS '作成日時';
COMMENT ON COLUMN inventories.shippings.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.shippings.created_by IS '作成者';
COMMENT ON COLUMN inventories.shippings.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.shippings ADD PRIMARY KEY (
  sipping_id
);

-- create index
CREATE INDEX idx_shippings_1 ON inventories.shippings (
  costomer_id,
  sipping_date,
  operation_timestamp
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.shippings
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.shippings_audit();
CREATE OR REPLACE FUNCTION inventories.shippings_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.sipping_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.sipping_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.sipping_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.shippings
  FOR EACH ROW
EXECUTE PROCEDURE inventories.shippings_audit();
