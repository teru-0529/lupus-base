-- Enum Type DDL

-- 買掛変動種類
DROP TYPE IF EXISTS payable_type;
CREATE TYPE payable_type AS enum (
  'PURCHASE',
  'ORDER_RETURN',
  'PAYMENT',
  'OTHER'
);

-- 支払状況
DROP TYPE IF EXISTS payment_status;
CREATE TYPE payment_status AS enum (
  'TO_BE_DETERMINED',
  'CONFIRMED',
  'COMPLETED'
);

-- Tables DDL

-- 15.支払(payments)

-- Create Table
DROP TABLE IF EXISTS inventories.payments CASCADE;
CREATE TABLE inventories.payments (
  payment_id varchar(10) NOT NULL check (payment_id ~* '^PM[0-9]{8}$'),
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
COMMENT ON COLUMN inventories.payments.payment_id IS '支払ID';
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
  payment_id
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
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.payment_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.payment_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.payment_id;
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

-- 16.月次買掛金サマリ(month_accounts_payables)

-- Create Table
DROP TABLE IF EXISTS inventories.month_accounts_payables CASCADE;
CREATE TABLE inventories.month_accounts_payables (
  supplier_id varchar(6) NOT NULL check (LENGTH(supplier_id) = 6),
  year_month varchar(6) NOT NULL check (year_month ~* '^[12][0-9]{3}(0[1-9]|1[0-2])$'),
  init_balance numeric NOT NULL DEFAULT 0.00,
  purchase_amount numeric NOT NULL DEFAULT 0.00,
  payment_amount numeric NOT NULL DEFAULT 0.00,
  other_amount numeric NOT NULL DEFAULT 0.00,
  present_balance numeric NOT NULL DEFAULT 0.00,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.month_accounts_payables IS '月次買掛金サマリ';

-- Set Column Comment
COMMENT ON COLUMN inventories.month_accounts_payables.supplier_id IS '仕入先ID';
COMMENT ON COLUMN inventories.month_accounts_payables.year_month IS '年月';
COMMENT ON COLUMN inventories.month_accounts_payables.init_balance IS '月初残高';
COMMENT ON COLUMN inventories.month_accounts_payables.purchase_amount IS '購入金額';
COMMENT ON COLUMN inventories.month_accounts_payables.payment_amount IS '支払金額';
COMMENT ON COLUMN inventories.month_accounts_payables.other_amount IS 'その他金額';
COMMENT ON COLUMN inventories.month_accounts_payables.present_balance IS '残高';
COMMENT ON COLUMN inventories.month_accounts_payables.created_at IS '作成日時';
COMMENT ON COLUMN inventories.month_accounts_payables.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.month_accounts_payables.created_by IS '作成者';
COMMENT ON COLUMN inventories.month_accounts_payables.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.month_accounts_payables ADD PRIMARY KEY (
  supplier_id,
  year_month
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.month_accounts_payables
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.month_accounts_payables_audit();
CREATE OR REPLACE FUNCTION inventories.month_accounts_payables_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.supplier_id || '-' || OLD.year_month;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.supplier_id || '-' || NEW.year_month;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.supplier_id || '-' || NEW.year_month;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.month_accounts_payables
  FOR EACH ROW
EXECUTE PROCEDURE inventories.month_accounts_payables_audit();

-- 17.現在買掛金サマリ(current_accounts_payables)

-- Create Table
DROP TABLE IF EXISTS inventories.current_accounts_payables CASCADE;
CREATE TABLE inventories.current_accounts_payables (
  supplier_id varchar(6) NOT NULL check (LENGTH(supplier_id) = 6),
  present_balance numeric NOT NULL DEFAULT 0.00,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.current_accounts_payables IS '現在買掛金サマリ';

-- Set Column Comment
COMMENT ON COLUMN inventories.current_accounts_payables.supplier_id IS '仕入先ID';
COMMENT ON COLUMN inventories.current_accounts_payables.present_balance IS '残高';
COMMENT ON COLUMN inventories.current_accounts_payables.created_at IS '作成日時';
COMMENT ON COLUMN inventories.current_accounts_payables.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.current_accounts_payables.created_by IS '作成者';
COMMENT ON COLUMN inventories.current_accounts_payables.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.current_accounts_payables ADD PRIMARY KEY (
  supplier_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.current_accounts_payables
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.current_accounts_payables_audit();
CREATE OR REPLACE FUNCTION inventories.current_accounts_payables_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.supplier_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.supplier_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.supplier_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.current_accounts_payables
  FOR EACH ROW
EXECUTE PROCEDURE inventories.current_accounts_payables_audit();

-- 18.買掛変動履歴(payable_histories)

-- Create Table
DROP TABLE IF EXISTS inventories.payable_histories CASCADE;
CREATE TABLE inventories.payable_histories (
  payable_no serial NOT NULL,
  business_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  supplier_id varchar(6) NOT NULL check (LENGTH(supplier_id) = 6),
  variable_amount numeric NOT NULL DEFAULT 0.00,
  payable_type payable_type NOT NULL,
  tranzaction_no serial NOT NULL,
  payment_id varchar(10) check (payment_id ~* '^PM[0-9]{8}$'),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.payable_histories IS '買掛変動履歴';

-- Set Column Comment
COMMENT ON COLUMN inventories.payable_histories.payable_no IS '買掛変動No';
COMMENT ON COLUMN inventories.payable_histories.business_date IS '業務取引日付';
COMMENT ON COLUMN inventories.payable_histories.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.payable_histories.supplier_id IS '仕入先ID';
COMMENT ON COLUMN inventories.payable_histories.variable_amount IS '変動金額';
COMMENT ON COLUMN inventories.payable_histories.payable_type IS '買掛変動種類';
COMMENT ON COLUMN inventories.payable_histories.tranzaction_no IS '取引管理No';
COMMENT ON COLUMN inventories.payable_histories.payment_id IS '支払ID';
COMMENT ON COLUMN inventories.payable_histories.created_at IS '作成日時';
COMMENT ON COLUMN inventories.payable_histories.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.payable_histories.created_by IS '作成者';
COMMENT ON COLUMN inventories.payable_histories.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.payable_histories ADD PRIMARY KEY (
  payable_no
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.payable_histories
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.payable_histories_audit();
CREATE OR REPLACE FUNCTION inventories.payable_histories_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.payable_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.payable_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.payable_no;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.payable_histories
  FOR EACH ROW
EXECUTE PROCEDURE inventories.payable_histories_audit();
