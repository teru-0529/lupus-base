-- is_master_table=false

-- 29.請求(bills)

-- Create Table
DROP TABLE IF EXISTS inventories.bills CASCADE;
CREATE TABLE inventories.bills (
  billing_id varchar(10) NOT NULL check (billing_id ~* '^BL-[0-9]{7}$'),
  costomer_id varchar(6) NOT NULL check (LENGTH(costomer_id) = 6),
  cut_off_date date NOT NULL DEFAULT get_business_date(),
  deposit_limit_date date NOT NULL DEFAULT get_business_date(),
  billing_amount numeric NOT NULL DEFAULT 0.00,
  applied_amount numeric NOT NULL DEFAULT 0.00,
  remaining_amount numeric NOT NULL DEFAULT 0.00,
  billing_status billing_status NOT NULL DEFAULT 'TO_BE_DETERMINED',
  amount_confirmed_date date,
  freeze_changed_timestamp timestamp,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.bills IS '請求';

-- Set Column Comment
COMMENT ON COLUMN inventories.bills.billing_id IS '請求番号';
COMMENT ON COLUMN inventories.bills.costomer_id IS '得意先ID';
COMMENT ON COLUMN inventories.bills.cut_off_date IS '締日付';
COMMENT ON COLUMN inventories.bills.deposit_limit_date IS '入金期限日付';
COMMENT ON COLUMN inventories.bills.billing_amount IS '請求金額';
COMMENT ON COLUMN inventories.bills.applied_amount IS '充当済金額';
COMMENT ON COLUMN inventories.bills.remaining_amount IS '残額';
COMMENT ON COLUMN inventories.bills.billing_status IS '請求状況';
COMMENT ON COLUMN inventories.bills.amount_confirmed_date IS '金額確定日付';
COMMENT ON COLUMN inventories.bills.freeze_changed_timestamp IS '変更凍結日時';
COMMENT ON COLUMN inventories.bills.created_at IS '作成日時';
COMMENT ON COLUMN inventories.bills.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.bills.created_by IS '作成者';
COMMENT ON COLUMN inventories.bills.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.bills ADD PRIMARY KEY (
  billing_id
);

-- Set Unique Constraint
ALTER TABLE inventories.bills ADD CONSTRAINT bills_unique_1 UNIQUE (
  costomer_id,
  cut_off_date,
  deposit_limit_date
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.bills
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.bills_audit();
CREATE OR REPLACE FUNCTION inventories.bills_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.billing_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.billing_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.billing_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.bills
  FOR EACH ROW
EXECUTE PROCEDURE inventories.bills_audit();
