-- is_master_table=true

-- 2.取引銀行(dealing_banks)

-- Create Table
DROP TABLE IF EXISTS inventories.dealing_banks CASCADE;
CREATE TABLE inventories.dealing_banks (
  company_id varchar(6) NOT NULL check (LENGTH(company_id) = 6),
  bank_code varchar(4) NOT NULL check (bank_code ~* '^[0-9]{4}$'),
  bank_name varchar(30) NOT NULL,
  bank_branch_code varchar(3) NOT NULL check (bank_branch_code ~* '^[0-9]{3}$'),
  bank_account_no varchar(50) NOT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.dealing_banks IS '取引銀行';

-- Set Column Comment
COMMENT ON COLUMN inventories.dealing_banks.company_id IS '企業ID';
COMMENT ON COLUMN inventories.dealing_banks.bank_code IS '銀行コード';
COMMENT ON COLUMN inventories.dealing_banks.bank_name IS '銀行名称';
COMMENT ON COLUMN inventories.dealing_banks.bank_branch_code IS '支店コード';
COMMENT ON COLUMN inventories.dealing_banks.bank_account_no IS '口座番号';
COMMENT ON COLUMN inventories.dealing_banks.created_at IS '作成日時';
COMMENT ON COLUMN inventories.dealing_banks.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.dealing_banks.created_by IS '作成者';
COMMENT ON COLUMN inventories.dealing_banks.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.dealing_banks ADD PRIMARY KEY (
  company_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.dealing_banks
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.dealing_banks_audit();
CREATE OR REPLACE FUNCTION inventories.dealing_banks_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.company_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.company_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.company_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.dealing_banks
  FOR EACH ROW
EXECUTE PROCEDURE inventories.dealing_banks_audit();
