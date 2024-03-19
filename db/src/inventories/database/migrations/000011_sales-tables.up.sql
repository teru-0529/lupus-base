-- Enum Type DDL

-- 売掛変動種類
DROP TYPE IF EXISTS receivable_type;
CREATE TYPE receivable_type AS enum (
  'SELES',
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

-- 32.現在売掛金サマリ(current_accounts_receivables)

-- Create Table
DROP TABLE IF EXISTS inventories.current_accounts_receivables CASCADE;
CREATE TABLE inventories.current_accounts_receivables (
  costomer_id varchar(6) NOT NULL check (LENGTH(costomer_id) = 6),
  present_balance numeric NOT NULL DEFAULT 0.00,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.current_accounts_receivables IS '現在売掛金サマリ';

-- Set Column Comment
COMMENT ON COLUMN inventories.current_accounts_receivables.costomer_id IS '得意先ID';
COMMENT ON COLUMN inventories.current_accounts_receivables.present_balance IS '残高';
COMMENT ON COLUMN inventories.current_accounts_receivables.created_at IS '作成日時';
COMMENT ON COLUMN inventories.current_accounts_receivables.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.current_accounts_receivables.created_by IS '作成者';
COMMENT ON COLUMN inventories.current_accounts_receivables.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.current_accounts_receivables ADD PRIMARY KEY (
  costomer_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.current_accounts_receivables
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.current_accounts_receivables_audit();
CREATE OR REPLACE FUNCTION inventories.current_accounts_receivables_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.costomer_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.costomer_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.costomer_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.current_accounts_receivables
  FOR EACH ROW
EXECUTE PROCEDURE inventories.current_accounts_receivables_audit();

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

-- 34.受注(receivings)

-- Create Table
DROP TABLE IF EXISTS inventories.receivings CASCADE;
CREATE TABLE inventories.receivings (
  receiving_id varchar(10) NOT NULL check (receiving_id ~* '^RO-[0-9]{7}$'),
  receiving_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  costomer_id varchar(6) NOT NULL check (LENGTH(costomer_id) = 6),
  sipping_priority integer NOT NULL DEFAULT 50 check (0 <= sipping_priority AND sipping_priority <= 100),
  note text,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.receivings IS '受注';

-- Set Column Comment
COMMENT ON COLUMN inventories.receivings.receiving_id IS '受注番号';
COMMENT ON COLUMN inventories.receivings.receiving_date IS '受注日付';
COMMENT ON COLUMN inventories.receivings.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.receivings.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.receivings.costomer_id IS '得意先ID';
COMMENT ON COLUMN inventories.receivings.sipping_priority IS '出荷優先度数';
COMMENT ON COLUMN inventories.receivings.note IS '備考';
COMMENT ON COLUMN inventories.receivings.created_at IS '作成日時';
COMMENT ON COLUMN inventories.receivings.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.receivings.created_by IS '作成者';
COMMENT ON COLUMN inventories.receivings.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.receivings ADD PRIMARY KEY (
  receiving_id
);

-- create index
CREATE INDEX idx_receivings_1 ON inventories.receivings (
  costomer_id,
  receiving_date,
  operation_timestamp
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.receivings
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.receivings_audit();
CREATE OR REPLACE FUNCTION inventories.receivings_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.receiving_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.receiving_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.receiving_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.receivings
  FOR EACH ROW
EXECUTE PROCEDURE inventories.receivings_audit();

-- 35.受注明細(receiving_details)

-- Create Table
DROP TABLE IF EXISTS inventories.receiving_details CASCADE;
CREATE TABLE inventories.receiving_details (
  receiving_id varchar(10) NOT NULL check (receiving_id ~* '^RO-[0-9]{7}$'),
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  receiving_quantity integer NOT NULL DEFAULT 0 check (receiving_quantity >= 0),
  shipping_quantity integer NOT NULL DEFAULT 0 check (shipping_quantity >= 0),
  cancel_quantity integer NOT NULL DEFAULT 0 check (cancel_quantity >= 0),
  remaining_quantity integer NOT NULL DEFAULT 0 check (remaining_quantity >= 0),
  selling_price numeric NOT NULL check (selling_price >= 0),
  estimate_cost_price numeric NOT NULL DEFAULT 0.00 check (estimate_cost_price >= 0),
  estimate_profit_rate numeric NOT NULL DEFAULT 0.00 check (estimate_profit_rate >= 0),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.receiving_details IS '受注明細';

-- Set Column Comment
COMMENT ON COLUMN inventories.receiving_details.receiving_id IS '受注番号';
COMMENT ON COLUMN inventories.receiving_details.product_id IS '商品ID';
COMMENT ON COLUMN inventories.receiving_details.receiving_quantity IS '受注数量';
COMMENT ON COLUMN inventories.receiving_details.shipping_quantity IS '出庫数量';
COMMENT ON COLUMN inventories.receiving_details.cancel_quantity IS 'キャンセル数量';
COMMENT ON COLUMN inventories.receiving_details.remaining_quantity IS '残数量';
COMMENT ON COLUMN inventories.receiving_details.selling_price IS '売価';
COMMENT ON COLUMN inventories.receiving_details.estimate_cost_price IS '想定原価';
COMMENT ON COLUMN inventories.receiving_details.estimate_profit_rate IS '想定利益率';
COMMENT ON COLUMN inventories.receiving_details.created_at IS '作成日時';
COMMENT ON COLUMN inventories.receiving_details.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.receiving_details.created_by IS '作成者';
COMMENT ON COLUMN inventories.receiving_details.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.receiving_details ADD PRIMARY KEY (
  receiving_id,
  product_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.receiving_details
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.receiving_details_audit();
CREATE OR REPLACE FUNCTION inventories.receiving_details_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.receiving_id || '-' || OLD.product_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.receiving_id || '-' || NEW.product_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.receiving_id || '-' || NEW.product_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.receiving_details
  FOR EACH ROW
EXECUTE PROCEDURE inventories.receiving_details_audit();

-- 36.出荷(shippings)

-- Create Table
DROP TABLE IF EXISTS inventories.shippings CASCADE;
CREATE TABLE inventories.shippings (
  sipping_id varchar(10) NOT NULL check (sipping_id ~* '^SP-[0-9]{7}$'),
  sipping_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  costomer_id varchar(6) NOT NULL check (LENGTH(costomer_id) = 6),
  cut_off_date date NOT NULL,
  deposit_limit_date date NOT NULL,
  billing_id varchar(10) NOT NULL check (billing_id ~* '^BL-[0-9]{7}$'),
  note text,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.shippings IS '出荷';

-- Set Column Comment
COMMENT ON COLUMN inventories.shippings.sipping_id IS '出荷番号';
COMMENT ON COLUMN inventories.shippings.sipping_date IS '出荷日付';
COMMENT ON COLUMN inventories.shippings.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.shippings.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.shippings.costomer_id IS '得意先ID';
COMMENT ON COLUMN inventories.shippings.cut_off_date IS '締日付';
COMMENT ON COLUMN inventories.shippings.deposit_limit_date IS '入金期限日付';
COMMENT ON COLUMN inventories.shippings.billing_id IS '請求番号';
COMMENT ON COLUMN inventories.shippings.note IS '備考';
COMMENT ON COLUMN inventories.shippings.created_at IS '作成日時';
COMMENT ON COLUMN inventories.shippings.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.shippings.created_by IS '作成者';
COMMENT ON COLUMN inventories.shippings.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.shippings ADD PRIMARY KEY (
  sipping_id
);

-- create index
CREATE INDEX idx_shippings_1 ON inventories.shippings (
  costomer_id,
  sipping_date,
  operation_timestamp
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.shippings
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.shippings_audit();
CREATE OR REPLACE FUNCTION inventories.shippings_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.sipping_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.sipping_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.sipping_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.shippings
  FOR EACH ROW
EXECUTE PROCEDURE inventories.shippings_audit();

-- 37.出荷明細(shipping_details)

-- Create Table
DROP TABLE IF EXISTS inventories.shipping_details CASCADE;
CREATE TABLE inventories.shipping_details (
  sipping_id varchar(10) NOT NULL check (sipping_id ~* '^SP-[0-9]{7}$'),
  receiving_id varchar(10) NOT NULL check (receiving_id ~* '^RO-[0-9]{7}$'),
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  shipping_quantity integer NOT NULL DEFAULT 0 check (shipping_quantity >= 0),
  return_quantity integer NOT NULL DEFAULT 0 check (return_quantity >= 0),
  selling_price numeric NOT NULL check (selling_price >= 0),
  cost_price numeric NOT NULL DEFAULT 0.00 check (cost_price >= 0),
  profit_rate numeric NOT NULL DEFAULT 0.00 check (profit_rate >= 0),
  site_id varchar(30) NOT NULL check (LENGTH(site_id) >= 1),
  shipping_detail_no serial NOT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.shipping_details IS '出荷明細';

-- Set Column Comment
COMMENT ON COLUMN inventories.shipping_details.sipping_id IS '出荷番号';
COMMENT ON COLUMN inventories.shipping_details.receiving_id IS '受注番号';
COMMENT ON COLUMN inventories.shipping_details.product_id IS '商品ID';
COMMENT ON COLUMN inventories.shipping_details.shipping_quantity IS '出庫数量';
COMMENT ON COLUMN inventories.shipping_details.return_quantity IS '返品数量';
COMMENT ON COLUMN inventories.shipping_details.selling_price IS '売価';
COMMENT ON COLUMN inventories.shipping_details.cost_price IS '原価';
COMMENT ON COLUMN inventories.shipping_details.profit_rate IS '利益率';
COMMENT ON COLUMN inventories.shipping_details.site_id IS '倉庫ID';
COMMENT ON COLUMN inventories.shipping_details.shipping_detail_no IS '出荷明細No';
COMMENT ON COLUMN inventories.shipping_details.created_at IS '作成日時';
COMMENT ON COLUMN inventories.shipping_details.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.shipping_details.created_by IS '作成者';
COMMENT ON COLUMN inventories.shipping_details.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.shipping_details ADD PRIMARY KEY (
  sipping_id,
  receiving_id,
  product_id
);

-- Set Unique Constraint
ALTER TABLE inventories.shipping_details ADD CONSTRAINT shipping_details_unique_1 UNIQUE (
  shipping_detail_no
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.shipping_details
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.shipping_details_audit();
CREATE OR REPLACE FUNCTION inventories.shipping_details_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.sipping_id || '-' || OLD.receiving_id || '-' || OLD.product_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.sipping_id || '-' || NEW.receiving_id || '-' || NEW.product_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.sipping_id || '-' || NEW.receiving_id || '-' || NEW.product_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.shipping_details
  FOR EACH ROW
EXECUTE PROCEDURE inventories.shipping_details_audit();

-- 38.受注キャンセル指示(receiving_cancel_instructions)

-- Create Table
DROP TABLE IF EXISTS inventories.receiving_cancel_instructions CASCADE;
CREATE TABLE inventories.receiving_cancel_instructions (
  cancel_instruction_no serial NOT NULL,
  business_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  instruction_cause text,
  receiving_id varchar(10) NOT NULL check (receiving_id ~* '^RO-[0-9]{7}$'),
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  quantity integer NOT NULL DEFAULT 0 check (quantity >= 0),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.receiving_cancel_instructions IS '受注キャンセル指示';

-- Set Column Comment
COMMENT ON COLUMN inventories.receiving_cancel_instructions.cancel_instruction_no IS 'キャンセル指示No';
COMMENT ON COLUMN inventories.receiving_cancel_instructions.business_date IS '業務取引日付';
COMMENT ON COLUMN inventories.receiving_cancel_instructions.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.receiving_cancel_instructions.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.receiving_cancel_instructions.instruction_cause IS '指示目的';
COMMENT ON COLUMN inventories.receiving_cancel_instructions.receiving_id IS '受注番号';
COMMENT ON COLUMN inventories.receiving_cancel_instructions.product_id IS '商品ID';
COMMENT ON COLUMN inventories.receiving_cancel_instructions.quantity IS '数量';
COMMENT ON COLUMN inventories.receiving_cancel_instructions.created_at IS '作成日時';
COMMENT ON COLUMN inventories.receiving_cancel_instructions.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.receiving_cancel_instructions.created_by IS '作成者';
COMMENT ON COLUMN inventories.receiving_cancel_instructions.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.receiving_cancel_instructions ADD PRIMARY KEY (
  cancel_instruction_no
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.receiving_cancel_instructions
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.receiving_cancel_instructions_audit();
CREATE OR REPLACE FUNCTION inventories.receiving_cancel_instructions_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.cancel_instruction_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.cancel_instruction_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.cancel_instruction_no;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.receiving_cancel_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.receiving_cancel_instructions_audit();

-- 39.請求金額確定指示(billing_confirm_instructions)

-- Create Table
DROP TABLE IF EXISTS inventories.billing_confirm_instructions CASCADE;
CREATE TABLE inventories.billing_confirm_instructions (
  amount_confirm_no serial NOT NULL,
  business_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  instruction_cause text,
  billing_id varchar(10) NOT NULL check (billing_id ~* '^BL-[0-9]{7}$'),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.billing_confirm_instructions IS '請求金額確定指示';

-- Set Column Comment
COMMENT ON COLUMN inventories.billing_confirm_instructions.amount_confirm_no IS '金額確定指示No';
COMMENT ON COLUMN inventories.billing_confirm_instructions.business_date IS '業務取引日付';
COMMENT ON COLUMN inventories.billing_confirm_instructions.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.billing_confirm_instructions.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.billing_confirm_instructions.instruction_cause IS '指示目的';
COMMENT ON COLUMN inventories.billing_confirm_instructions.billing_id IS '請求番号';
COMMENT ON COLUMN inventories.billing_confirm_instructions.created_at IS '作成日時';
COMMENT ON COLUMN inventories.billing_confirm_instructions.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.billing_confirm_instructions.created_by IS '作成者';
COMMENT ON COLUMN inventories.billing_confirm_instructions.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.billing_confirm_instructions ADD PRIMARY KEY (
  amount_confirm_no
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.billing_confirm_instructions
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.billing_confirm_instructions_audit();
CREATE OR REPLACE FUNCTION inventories.billing_confirm_instructions_audit() RETURNS TRIGGER AS $$
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
  ON inventories.billing_confirm_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.billing_confirm_instructions_audit();

-- 40.出荷返品指示(shipping_return_instructions)

-- Create Table
DROP TABLE IF EXISTS inventories.shipping_return_instructions CASCADE;
CREATE TABLE inventories.shipping_return_instructions (
  return_instruction_no serial NOT NULL,
  business_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  instruction_cause text,
  sipping_id varchar(10) NOT NULL check (sipping_id ~* '^SP-[0-9]{7}$'),
  receiving_id varchar(10) NOT NULL check (receiving_id ~* '^RO-[0-9]{7}$'),
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  site_id varchar(30) NOT NULL check (LENGTH(site_id) >= 1),
  quantity integer NOT NULL DEFAULT 0 check (quantity >= 0),
  selling_price numeric NOT NULL check (selling_price >= 0),
  cost_price numeric NOT NULL check (cost_price >= 0),
  cut_off_date date NOT NULL,
  deposit_limit_date date NOT NULL,
  billing_id varchar(10) NOT NULL check (billing_id ~* '^BL-[0-9]{7}$'),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.shipping_return_instructions IS '出荷返品指示';

-- Set Column Comment
COMMENT ON COLUMN inventories.shipping_return_instructions.return_instruction_no IS '返品指示No';
COMMENT ON COLUMN inventories.shipping_return_instructions.business_date IS '業務取引日付';
COMMENT ON COLUMN inventories.shipping_return_instructions.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.shipping_return_instructions.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.shipping_return_instructions.instruction_cause IS '指示目的';
COMMENT ON COLUMN inventories.shipping_return_instructions.sipping_id IS '出荷番号';
COMMENT ON COLUMN inventories.shipping_return_instructions.receiving_id IS '受注番号';
COMMENT ON COLUMN inventories.shipping_return_instructions.product_id IS '商品ID';
COMMENT ON COLUMN inventories.shipping_return_instructions.site_id IS '倉庫ID';
COMMENT ON COLUMN inventories.shipping_return_instructions.quantity IS '数量';
COMMENT ON COLUMN inventories.shipping_return_instructions.selling_price IS '売価';
COMMENT ON COLUMN inventories.shipping_return_instructions.cost_price IS '原価';
COMMENT ON COLUMN inventories.shipping_return_instructions.cut_off_date IS '締日付';
COMMENT ON COLUMN inventories.shipping_return_instructions.deposit_limit_date IS '入金期限日付';
COMMENT ON COLUMN inventories.shipping_return_instructions.billing_id IS '請求番号';
COMMENT ON COLUMN inventories.shipping_return_instructions.created_at IS '作成日時';
COMMENT ON COLUMN inventories.shipping_return_instructions.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.shipping_return_instructions.created_by IS '作成者';
COMMENT ON COLUMN inventories.shipping_return_instructions.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.shipping_return_instructions ADD PRIMARY KEY (
  return_instruction_no
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.shipping_return_instructions
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.shipping_return_instructions_audit();
CREATE OR REPLACE FUNCTION inventories.shipping_return_instructions_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.return_instruction_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.return_instruction_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.return_instruction_no;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.shipping_return_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.shipping_return_instructions_audit();

-- 41.売掛金修正指示(correct_receivable_instructions)

-- Create Table
DROP TABLE IF EXISTS inventories.correct_receivable_instructions CASCADE;
CREATE TABLE inventories.correct_receivable_instructions (
  receivable_correct_instruction_no serial NOT NULL,
  business_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  instruction_cause text,
  costomer_id varchar(6) NOT NULL check (LENGTH(costomer_id) = 6),
  variable_amount numeric NOT NULL DEFAULT 0.00,
  cut_off_date date NOT NULL,
  deposit_limit_date date NOT NULL,
  billing_id varchar(10) NOT NULL check (billing_id ~* '^BL-[0-9]{7}$'),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.correct_receivable_instructions IS '売掛金修正指示';

-- Set Column Comment
COMMENT ON COLUMN inventories.correct_receivable_instructions.receivable_correct_instruction_no IS '売掛修正指示No';
COMMENT ON COLUMN inventories.correct_receivable_instructions.business_date IS '業務取引日付';
COMMENT ON COLUMN inventories.correct_receivable_instructions.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.correct_receivable_instructions.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.correct_receivable_instructions.instruction_cause IS '指示目的';
COMMENT ON COLUMN inventories.correct_receivable_instructions.costomer_id IS '得意先ID';
COMMENT ON COLUMN inventories.correct_receivable_instructions.variable_amount IS '変動金額';
COMMENT ON COLUMN inventories.correct_receivable_instructions.cut_off_date IS '締日付';
COMMENT ON COLUMN inventories.correct_receivable_instructions.deposit_limit_date IS '入金期限日付';
COMMENT ON COLUMN inventories.correct_receivable_instructions.billing_id IS '請求番号';
COMMENT ON COLUMN inventories.correct_receivable_instructions.created_at IS '作成日時';
COMMENT ON COLUMN inventories.correct_receivable_instructions.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.correct_receivable_instructions.created_by IS '作成者';
COMMENT ON COLUMN inventories.correct_receivable_instructions.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.correct_receivable_instructions ADD PRIMARY KEY (
  receivable_correct_instruction_no
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.correct_receivable_instructions
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.correct_receivable_instructions_audit();
CREATE OR REPLACE FUNCTION inventories.correct_receivable_instructions_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.receivable_correct_instruction_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.receivable_correct_instruction_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.receivable_correct_instruction_no;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.correct_receivable_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.correct_receivable_instructions_audit();

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
