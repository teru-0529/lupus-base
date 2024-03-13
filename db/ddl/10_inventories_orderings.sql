-- is_master_table=false

-- 19.発注(orderings)

-- Create Table
DROP TABLE IF EXISTS inventories.orderings CASCADE;
CREATE TABLE inventories.orderings (
  ordering_id varchar(10) NOT NULL check (ordering_id ~* '^PO-[0-9]{7}$'),
  order_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  supplier_id varchar(6) NOT NULL check (LENGTH(supplier_id) = 6),
  note text,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.orderings IS '発注';

-- Set Column Comment
COMMENT ON COLUMN inventories.orderings.ordering_id IS '発注番号';
COMMENT ON COLUMN inventories.orderings.order_date IS '発注日付';
COMMENT ON COLUMN inventories.orderings.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.orderings.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.orderings.supplier_id IS '仕入先ID';
COMMENT ON COLUMN inventories.orderings.note IS '備考';
COMMENT ON COLUMN inventories.orderings.created_at IS '作成日時';
COMMENT ON COLUMN inventories.orderings.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.orderings.created_by IS '作成者';
COMMENT ON COLUMN inventories.orderings.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.orderings ADD PRIMARY KEY (
  ordering_id
);

-- create index
CREATE INDEX idx_orderings_1 ON inventories.orderings (
  supplier_id,
  order_date,
  operation_timestamp
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.orderings
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.orderings_audit();
CREATE OR REPLACE FUNCTION inventories.orderings_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.ordering_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.ordering_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.ordering_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.orderings
  FOR EACH ROW
EXECUTE PROCEDURE inventories.orderings_audit();
