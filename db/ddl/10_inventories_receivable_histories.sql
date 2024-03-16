-- is_master_table=false

-- 33.売掛変動履歴(receivable_histories)

-- Create Table
DROP TABLE IF EXISTS inventories.receivable_histories CASCADE;
CREATE TABLE inventories.receivable_histories (
  receivable_no serial NOT NULL,
  business_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  costomer_id varchar(6) NOT NULL check (LENGTH(costomer_id) = 6),
  variable_amount numeric NOT NULL DEFAULT 0.00,
  receivable_type receivable_type NOT NULL,
  tranzaction_no serial NOT NULL,
  billing_id varchar(10) check (billing_id ~* '^BL-[0-9]{7}$'),
  deposit_id varchar(10) check (deposit_id ~* '^DP-[0-9]{7}$'),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.receivable_histories IS '売掛変動履歴';

-- Set Column Comment
COMMENT ON COLUMN inventories.receivable_histories.receivable_no IS '売掛変動No';
COMMENT ON COLUMN inventories.receivable_histories.business_date IS '業務取引日付';
COMMENT ON COLUMN inventories.receivable_histories.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.receivable_histories.costomer_id IS '得意先ID';
COMMENT ON COLUMN inventories.receivable_histories.variable_amount IS '変動金額';
COMMENT ON COLUMN inventories.receivable_histories.receivable_type IS '売掛変動種類';
COMMENT ON COLUMN inventories.receivable_histories.tranzaction_no IS '取引管理No';
COMMENT ON COLUMN inventories.receivable_histories.billing_id IS '請求番号';
COMMENT ON COLUMN inventories.receivable_histories.deposit_id IS '入金番号';
COMMENT ON COLUMN inventories.receivable_histories.created_at IS '作成日時';
COMMENT ON COLUMN inventories.receivable_histories.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.receivable_histories.created_by IS '作成者';
COMMENT ON COLUMN inventories.receivable_histories.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.receivable_histories ADD PRIMARY KEY (
  receivable_no
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.receivable_histories
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.receivable_histories_audit();
CREATE OR REPLACE FUNCTION inventories.receivable_histories_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.receivable_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.receivable_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.receivable_no;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.receivable_histories
  FOR EACH ROW
EXECUTE PROCEDURE inventories.receivable_histories_audit();
