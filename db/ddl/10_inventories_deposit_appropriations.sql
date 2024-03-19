-- is_master_table=false

-- 42.入金充当(deposit_appropriations)

-- Create Table
DROP TABLE IF EXISTS inventories.deposit_appropriations CASCADE;
CREATE TABLE inventories.deposit_appropriations (
  billing_id varchar(10) NOT NULL check (billing_id ~* '^BL-[0-9]{7}$'),
  deposit_id varchar(10) NOT NULL check (deposit_id ~* '^DP-[0-9]{7}$'),
  applied_amount numeric NOT NULL DEFAULT 0.00,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.deposit_appropriations IS '入金充当';

-- Set Column Comment
COMMENT ON COLUMN inventories.deposit_appropriations.billing_id IS '請求番号';
COMMENT ON COLUMN inventories.deposit_appropriations.deposit_id IS '入金番号';
COMMENT ON COLUMN inventories.deposit_appropriations.applied_amount IS '充当済金額';
COMMENT ON COLUMN inventories.deposit_appropriations.created_at IS '作成日時';
COMMENT ON COLUMN inventories.deposit_appropriations.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.deposit_appropriations.created_by IS '作成者';
COMMENT ON COLUMN inventories.deposit_appropriations.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.deposit_appropriations ADD PRIMARY KEY (
  billing_id,
  deposit_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.deposit_appropriations
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.deposit_appropriations_audit();
CREATE OR REPLACE FUNCTION inventories.deposit_appropriations_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.billing_id || '-' || OLD.deposit_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.billing_id || '-' || NEW.deposit_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.billing_id || '-' || NEW.deposit_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.deposit_appropriations
  FOR EACH ROW
EXECUTE PROCEDURE inventories.deposit_appropriations_audit();
