-- is_master_table=false

-- 34.受注(receivings)

-- Create Table
DROP TABLE IF EXISTS inventories.receivings CASCADE;
CREATE TABLE inventories.receivings (
  receiving_id varchar(10) NOT NULL check (receiving_id ~* '^RO-[0-9]{7}$'),
  receiving_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  costomer_id varchar(6) NOT NULL check (LENGTH(costomer_id) = 6),
  sipping_priority integer NOT NULL DEFAULT 50 check (0 <= sipping_priority AND sipping_priority <= 100),
  note text,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.receivings IS '受注';

-- Set Column Comment
COMMENT ON COLUMN inventories.receivings.receiving_id IS '受注番号';
COMMENT ON COLUMN inventories.receivings.receiving_date IS '受注日付';
COMMENT ON COLUMN inventories.receivings.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.receivings.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.receivings.costomer_id IS '得意先ID';
COMMENT ON COLUMN inventories.receivings.sipping_priority IS '出荷優先度数';
COMMENT ON COLUMN inventories.receivings.note IS '備考';
COMMENT ON COLUMN inventories.receivings.created_at IS '作成日時';
COMMENT ON COLUMN inventories.receivings.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.receivings.created_by IS '作成者';
COMMENT ON COLUMN inventories.receivings.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.receivings ADD PRIMARY KEY (
  receiving_id
);

-- create index
CREATE INDEX idx_receivings_1 ON inventories.receivings (
  costomer_id,
  receiving_date,
  operation_timestamp
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.receivings
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.receivings_audit();
CREATE OR REPLACE FUNCTION inventories.receivings_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.receiving_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.receiving_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.receiving_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.receivings
  FOR EACH ROW
EXECUTE PROCEDURE inventories.receivings_audit();
