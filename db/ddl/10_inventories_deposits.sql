-- is_master_table=false

-- 30.入金(deposits)

-- Create Table
DROP TABLE IF EXISTS inventories.deposits CASCADE;
CREATE TABLE inventories.deposits (
  deposit_id varchar(10) NOT NULL check (deposit_id ~* '^DP-[0-9]{7}$'),
  deposit_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  costomer_id varchar(6) NOT NULL check (LENGTH(costomer_id) = 6),
  deposit_amount numeric NOT NULL DEFAULT 0.00,
  applied_amount numeric NOT NULL DEFAULT 0.00,
  remaining_amount numeric NOT NULL DEFAULT 0.00,
  deposit_instruction_no serial NOT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.deposits IS '入金';

-- Set Column Comment
COMMENT ON COLUMN inventories.deposits.deposit_id IS '入金番号';
COMMENT ON COLUMN inventories.deposits.deposit_date IS '入金日付';
COMMENT ON COLUMN inventories.deposits.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.deposits.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.deposits.costomer_id IS '得意先ID';
COMMENT ON COLUMN inventories.deposits.deposit_amount IS '入金金額';
COMMENT ON COLUMN inventories.deposits.applied_amount IS '充当済金額';
COMMENT ON COLUMN inventories.deposits.remaining_amount IS '残額';
COMMENT ON COLUMN inventories.deposits.deposit_instruction_no IS '入金指示No';
COMMENT ON COLUMN inventories.deposits.created_at IS '作成日時';
COMMENT ON COLUMN inventories.deposits.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.deposits.created_by IS '作成者';
COMMENT ON COLUMN inventories.deposits.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.deposits ADD PRIMARY KEY (
  deposit_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.deposits
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.deposits_audit();
CREATE OR REPLACE FUNCTION inventories.deposits_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.deposit_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.deposit_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.deposit_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.deposits
  FOR EACH ROW
EXECUTE PROCEDURE inventories.deposits_audit();
