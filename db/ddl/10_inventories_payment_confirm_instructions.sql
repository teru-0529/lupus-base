-- is_master_table=false

-- 25.支払金額確定指示(payment_confirm_instructions)

-- Create Table
DROP TABLE IF EXISTS inventories.payment_confirm_instructions CASCADE;
CREATE TABLE inventories.payment_confirm_instructions (
  amount_confirm_no serial NOT NULL,
  business_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  instruction_cause text,
  payment_id varchar(10) NOT NULL check (payment_id ~* '^PM-[0-9]{7}$'),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.payment_confirm_instructions IS '支払金額確定指示';

-- Set Column Comment
COMMENT ON COLUMN inventories.payment_confirm_instructions.amount_confirm_no IS '金額確定指示No';
COMMENT ON COLUMN inventories.payment_confirm_instructions.business_date IS '業務取引日付';
COMMENT ON COLUMN inventories.payment_confirm_instructions.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.payment_confirm_instructions.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.payment_confirm_instructions.instruction_cause IS '指示目的';
COMMENT ON COLUMN inventories.payment_confirm_instructions.payment_id IS '支払番号';
COMMENT ON COLUMN inventories.payment_confirm_instructions.created_at IS '作成日時';
COMMENT ON COLUMN inventories.payment_confirm_instructions.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.payment_confirm_instructions.created_by IS '作成者';
COMMENT ON COLUMN inventories.payment_confirm_instructions.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.payment_confirm_instructions ADD PRIMARY KEY (
  amount_confirm_no
);

-- create index
CREATE INDEX idx_payment_confirm_instructions_1 ON inventories.payment_confirm_instructions (
  payment_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.payment_confirm_instructions
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.payment_confirm_instructions_audit();
CREATE OR REPLACE FUNCTION inventories.payment_confirm_instructions_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.amount_confirm_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.amount_confirm_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.amount_confirm_no;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.payment_confirm_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.payment_confirm_instructions_audit();
