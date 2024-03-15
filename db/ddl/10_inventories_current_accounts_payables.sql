-- is_master_table=false

-- 17.現在買掛金サマリ(current_accounts_payables)

-- Create Table
DROP TABLE IF EXISTS inventories.current_accounts_payables CASCADE;
CREATE TABLE inventories.current_accounts_payables (
  supplier_id varchar(6) NOT NULL check (LENGTH(supplier_id) = 6),
  present_balance numeric NOT NULL DEFAULT 0.00,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.current_accounts_payables IS '現在買掛金サマリ';

-- Set Column Comment
COMMENT ON COLUMN inventories.current_accounts_payables.supplier_id IS '仕入先ID';
COMMENT ON COLUMN inventories.current_accounts_payables.present_balance IS '残高';
COMMENT ON COLUMN inventories.current_accounts_payables.created_at IS '作成日時';
COMMENT ON COLUMN inventories.current_accounts_payables.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.current_accounts_payables.created_by IS '作成者';
COMMENT ON COLUMN inventories.current_accounts_payables.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.current_accounts_payables ADD PRIMARY KEY (
  supplier_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.current_accounts_payables
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.current_accounts_payables_audit();
CREATE OR REPLACE FUNCTION inventories.current_accounts_payables_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.supplier_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.supplier_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.supplier_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.current_accounts_payables
  FOR EACH ROW
EXECUTE PROCEDURE inventories.current_accounts_payables_audit();
