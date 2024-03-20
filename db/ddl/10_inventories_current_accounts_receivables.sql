-- is_master_table=false

-- 32.現在売掛金サマリ(current_accounts_receivables)

-- Create Table
DROP TABLE IF EXISTS inventories.current_accounts_receivables CASCADE;
CREATE TABLE inventories.current_accounts_receivables (
  costomer_id varchar(6) NOT NULL check (LENGTH(costomer_id) = 6),
  present_balance numeric NOT NULL DEFAULT 0.00,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.current_accounts_receivables IS '現在売掛金サマリ';

-- Set Column Comment
COMMENT ON COLUMN inventories.current_accounts_receivables.costomer_id IS '得意先ID';
COMMENT ON COLUMN inventories.current_accounts_receivables.present_balance IS '残高';
COMMENT ON COLUMN inventories.current_accounts_receivables.created_at IS '作成日時';
COMMENT ON COLUMN inventories.current_accounts_receivables.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.current_accounts_receivables.created_by IS '作成者';
COMMENT ON COLUMN inventories.current_accounts_receivables.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.current_accounts_receivables ADD PRIMARY KEY (
  costomer_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.current_accounts_receivables
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.current_accounts_receivables_audit();
CREATE OR REPLACE FUNCTION inventories.current_accounts_receivables_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.costomer_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.costomer_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.costomer_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.current_accounts_receivables
  FOR EACH ROW
EXECUTE PROCEDURE inventories.current_accounts_receivables_audit();
