-- is_master_table=false

-- 15.支払(payments)

-- Create Table
DROP TABLE IF EXISTS inventories.payments CASCADE;
CREATE TABLE inventories.payments (
  paymant_id varchar(10) NOT NULL check (paymant_id ~* '^PM[0-9]{8}$'),
  supplier_id varchar(6) NOT NULL check (LENGTH(supplier_id) = 6),
  cut_off_date date NOT NULL DEFAULT get_business_date(),
  deposit_date date NOT NULL DEFAULT get_business_date(),
  payment_amount numeric NOT NULL DEFAULT 0.00,
  payment_status payment_status NOT NULL,
  change_deadline_date date NOT NULL DEFAULT get_business_date(),
  amount_confirmed_date date,
  payment_date date,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.payments IS '支払';

-- Set Column Comment
COMMENT ON COLUMN inventories.payments.paymant_id IS '支払ID';
COMMENT ON COLUMN inventories.payments.supplier_id IS '仕入先ID';
COMMENT ON COLUMN inventories.payments.cut_off_date IS '締日付';
COMMENT ON COLUMN inventories.payments.deposit_date IS '支払期限日付';
COMMENT ON COLUMN inventories.payments.payment_amount IS '支払金額';
COMMENT ON COLUMN inventories.payments.payment_status IS '支払状況';
COMMENT ON COLUMN inventories.payments.change_deadline_date IS '変更期限日付';
COMMENT ON COLUMN inventories.payments.amount_confirmed_date IS '金額確定日付';
COMMENT ON COLUMN inventories.payments.payment_date IS '支払日付';
COMMENT ON COLUMN inventories.payments.created_at IS '作成日時';
COMMENT ON COLUMN inventories.payments.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.payments.created_by IS '作成者';
COMMENT ON COLUMN inventories.payments.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.payments ADD PRIMARY KEY (
  paymant_id
);

-- Set Unique Constraint
ALTER TABLE inventories.payments ADD CONSTRAINT payments_unique_1 UNIQUE (
  supplier_id,
  cut_off_date,
  deposit_date
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.payments
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.payments_audit();
CREATE OR REPLACE FUNCTION inventories.payments_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.paymant_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.paymant_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.paymant_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.payments
  FOR EACH ROW
EXECUTE PROCEDURE inventories.payments_audit();
