-- is_master_table=false

-- 31.月次売掛金サマリ(month_accounts_receivables)

-- Create Table
DROP TABLE IF EXISTS inventories.month_accounts_receivables CASCADE;
CREATE TABLE inventories.month_accounts_receivables (
  costomer_id varchar(6) NOT NULL check (LENGTH(costomer_id) = 6),
  year_month varchar(6) NOT NULL check (year_month ~* '^[12][0-9]{3}(0[1-9]|1[0-2])$'),
  init_balance numeric NOT NULL DEFAULT 0.00,
  sales_amount numeric NOT NULL DEFAULT 0.00,
  deposit_amount numeric NOT NULL DEFAULT 0.00,
  other_amount numeric NOT NULL DEFAULT 0.00,
  present_balance numeric NOT NULL DEFAULT 0.00,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.month_accounts_receivables IS '月次売掛金サマリ';

-- Set Column Comment
COMMENT ON COLUMN inventories.month_accounts_receivables.costomer_id IS '得意先ID';
COMMENT ON COLUMN inventories.month_accounts_receivables.year_month IS '年月';
COMMENT ON COLUMN inventories.month_accounts_receivables.init_balance IS '月初残高';
COMMENT ON COLUMN inventories.month_accounts_receivables.sales_amount IS '売上金額';
COMMENT ON COLUMN inventories.month_accounts_receivables.deposit_amount IS '入金金額';
COMMENT ON COLUMN inventories.month_accounts_receivables.other_amount IS 'その他金額';
COMMENT ON COLUMN inventories.month_accounts_receivables.present_balance IS '残高';
COMMENT ON COLUMN inventories.month_accounts_receivables.created_at IS '作成日時';
COMMENT ON COLUMN inventories.month_accounts_receivables.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.month_accounts_receivables.created_by IS '作成者';
COMMENT ON COLUMN inventories.month_accounts_receivables.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.month_accounts_receivables ADD PRIMARY KEY (
  costomer_id,
  year_month
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.month_accounts_receivables
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.month_accounts_receivables_audit();
CREATE OR REPLACE FUNCTION inventories.month_accounts_receivables_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.costomer_id || '-' || OLD.year_month;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.costomer_id || '-' || NEW.year_month;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.costomer_id || '-' || NEW.year_month;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.month_accounts_receivables
  FOR EACH ROW
EXECUTE PROCEDURE inventories.month_accounts_receivables_audit();
