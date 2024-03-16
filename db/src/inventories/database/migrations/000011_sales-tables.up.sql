-- Enum Type DDL

-- 売掛変動種類
DROP TYPE IF EXISTS receivable_type;
CREATE TYPE receivable_type AS enum (
  'SELLING',
  'SALES_RETURN',
  'DEPOSIT',
  'OTHER'
);

-- 請求状況
DROP TYPE IF EXISTS billing_status;
CREATE TYPE billing_status AS enum (
  'TO_BE_DETERMINED',
  'CONFIRMED',
  'PART_OF_DEPOSITED',
  'COMPLETED'
);

-- 曜日
DROP TYPE IF EXISTS week;
CREATE TYPE week AS enum (
  'SUN',
  'MON',
  'TUE',
  'WED',
  'THU',
  'FRI',
  'SAT'
);

-- 商品入荷状況
DROP TYPE IF EXISTS product_shipping_situation;
CREATE TYPE product_shipping_situation AS enum (
  'IN_STOCK',
  'ON_INSPECT',
  'ORDERING',
  'ORDER_PREPARING'
);

-- Tables DDL

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
