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
  payment_id varchar(10) NOT NULL check (payment_id ~* '^PM-[0-9]{7}$'),
  supplier_id varchar(6) NOT NULL check (LENGTH(supplier_id) = 6),
  cut_off_date date NOT NULL DEFAULT get_business_date(),
  payment_limit_date date NOT NULL DEFAULT get_business_date(),
  payment_amount numeric NOT NULL DEFAULT 0.00,
  payment_status payment_status NOT NULL DEFAULT 'TO_BE_DETERMINED',
  amount_confirmed_date date,
  payment_date date,
  freeze_changed_timestamp timestamp,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.payments IS '支払';

-- Set Column Comment
COMMENT ON COLUMN inventories.payments.payment_id IS '支払番号';
COMMENT ON COLUMN inventories.payments.supplier_id IS '仕入先ID';
COMMENT ON COLUMN inventories.payments.cut_off_date IS '締日付';
COMMENT ON COLUMN inventories.payments.payment_limit_date IS '支払期限日付';
COMMENT ON COLUMN inventories.payments.payment_amount IS '支払金額';
COMMENT ON COLUMN inventories.payments.payment_status IS '支払状況';
COMMENT ON COLUMN inventories.payments.amount_confirmed_date IS '金額確定日付';
COMMENT ON COLUMN inventories.payments.payment_date IS '支払日付';
COMMENT ON COLUMN inventories.payments.freeze_changed_timestamp IS '変更凍結日時';
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
  payment_limit_date
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
  payment_id varchar(10) check (payment_id ~* '^PM-[0-9]{7}$'),
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
COMMENT ON COLUMN inventories.payable_histories.payment_id IS '支払番号';
COMMENT ON COLUMN inventories.payable_histories.created_at IS '作成日時';
COMMENT ON COLUMN inventories.payable_histories.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.payable_histories.created_by IS '作成者';
COMMENT ON COLUMN inventories.payable_histories.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.payable_histories ADD PRIMARY KEY (
  payable_no
);

-- create index
CREATE INDEX idx_payable_histories_1 ON inventories.payable_histories (
  supplier_id,
  business_date,
  operation_timestamp
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

-- 19.発注(orderings)

-- Create Table
DROP TABLE IF EXISTS inventories.orderings CASCADE;
CREATE TABLE inventories.orderings (
  ordering_id varchar(10) NOT NULL check (ordering_id ~* '^PO-[0-9]{7}$'),
  order_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  supplier_id varchar(6) NOT NULL check (LENGTH(supplier_id) = 6),
  note text,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.orderings IS '発注';

-- Set Column Comment
COMMENT ON COLUMN inventories.orderings.ordering_id IS '発注番号';
COMMENT ON COLUMN inventories.orderings.order_date IS '発注日付';
COMMENT ON COLUMN inventories.orderings.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.orderings.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.orderings.supplier_id IS '仕入先ID';
COMMENT ON COLUMN inventories.orderings.note IS '備考';
COMMENT ON COLUMN inventories.orderings.created_at IS '作成日時';
COMMENT ON COLUMN inventories.orderings.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.orderings.created_by IS '作成者';
COMMENT ON COLUMN inventories.orderings.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.orderings ADD PRIMARY KEY (
  ordering_id
);

-- create index
CREATE INDEX idx_orderings_1 ON inventories.orderings (
  supplier_id,
  order_date,
  operation_timestamp
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.orderings
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.orderings_audit();
CREATE OR REPLACE FUNCTION inventories.orderings_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.ordering_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.ordering_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.ordering_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.orderings
  FOR EACH ROW
EXECUTE PROCEDURE inventories.orderings_audit();

-- 20.発注明細(ordering_details)

-- Create Table
DROP TABLE IF EXISTS inventories.ordering_details CASCADE;
CREATE TABLE inventories.ordering_details (
  ordering_id varchar(10) NOT NULL check (ordering_id ~* '^PO-[0-9]{7}$'),
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  ordering_quantity integer NOT NULL DEFAULT 0 check (ordering_quantity >= 0),
  warehousing_quantity integer NOT NULL DEFAULT 0 check (warehousing_quantity >= 0),
  cancel_quantity integer NOT NULL DEFAULT 0 check (cancel_quantity >= 0),
  remaining_quantity integer NOT NULL DEFAULT 0 check (remaining_quantity >= 0),
  unit_price numeric NOT NULL check (unit_price >= 0),
  estimate_profit_rate numeric NOT NULL DEFAULT 0.00 check (estimate_profit_rate >= 0),
  standard_arrival_date date NOT NULL DEFAULT get_business_date(),
  estimate_arrival_date date NOT NULL DEFAULT get_business_date(),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.ordering_details IS '発注明細';

-- Set Column Comment
COMMENT ON COLUMN inventories.ordering_details.ordering_id IS '発注番号';
COMMENT ON COLUMN inventories.ordering_details.product_id IS '商品ID';
COMMENT ON COLUMN inventories.ordering_details.ordering_quantity IS '発注数量';
COMMENT ON COLUMN inventories.ordering_details.warehousing_quantity IS '入庫数量';
COMMENT ON COLUMN inventories.ordering_details.cancel_quantity IS 'キャンセル数量';
COMMENT ON COLUMN inventories.ordering_details.remaining_quantity IS '残数量';
COMMENT ON COLUMN inventories.ordering_details.unit_price IS '単価';
COMMENT ON COLUMN inventories.ordering_details.estimate_profit_rate IS '想定利益率';
COMMENT ON COLUMN inventories.ordering_details.standard_arrival_date IS '標準納期日付';
COMMENT ON COLUMN inventories.ordering_details.estimate_arrival_date IS '予定納期日付';
COMMENT ON COLUMN inventories.ordering_details.created_at IS '作成日時';
COMMENT ON COLUMN inventories.ordering_details.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.ordering_details.created_by IS '作成者';
COMMENT ON COLUMN inventories.ordering_details.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.ordering_details ADD PRIMARY KEY (
  ordering_id,
  product_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.ordering_details
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.ordering_details_audit();
CREATE OR REPLACE FUNCTION inventories.ordering_details_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.ordering_id || '-' || OLD.product_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.ordering_id || '-' || NEW.product_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.ordering_id || '-' || NEW.product_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.ordering_details
  FOR EACH ROW
EXECUTE PROCEDURE inventories.ordering_details_audit();

-- 21.入荷(warehousings)

-- Create Table
DROP TABLE IF EXISTS inventories.warehousings CASCADE;
CREATE TABLE inventories.warehousings (
  warehousing_id varchar(10) NOT NULL check (warehousing_id ~* '^WH-[0-9]{7}$'),
  warehouse_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  supplier_id varchar(6) NOT NULL check (LENGTH(supplier_id) = 6),
  cut_off_date date NOT NULL,
  payment_limit_date date NOT NULL,
  payment_id varchar(10) NOT NULL check (payment_id ~* '^PM-[0-9]{7}$'),
  note text,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.warehousings IS '入荷';

-- Set Column Comment
COMMENT ON COLUMN inventories.warehousings.warehousing_id IS '入荷番号';
COMMENT ON COLUMN inventories.warehousings.warehouse_date IS '入荷日付';
COMMENT ON COLUMN inventories.warehousings.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.warehousings.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.warehousings.supplier_id IS '仕入先ID';
COMMENT ON COLUMN inventories.warehousings.cut_off_date IS '締日付';
COMMENT ON COLUMN inventories.warehousings.payment_limit_date IS '支払期限日付';
COMMENT ON COLUMN inventories.warehousings.payment_id IS '支払番号';
COMMENT ON COLUMN inventories.warehousings.note IS '備考';
COMMENT ON COLUMN inventories.warehousings.created_at IS '作成日時';
COMMENT ON COLUMN inventories.warehousings.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.warehousings.created_by IS '作成者';
COMMENT ON COLUMN inventories.warehousings.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.warehousings ADD PRIMARY KEY (
  warehousing_id
);

-- create index
CREATE INDEX idx_warehousings_1 ON inventories.warehousings (
  supplier_id,
  cut_off_date,
  payment_limit_date
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.warehousings
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.warehousings_audit();
CREATE OR REPLACE FUNCTION inventories.warehousings_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.warehousing_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.warehousing_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.warehousing_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.warehousings
  FOR EACH ROW
EXECUTE PROCEDURE inventories.warehousings_audit();

-- 22.入荷明細(warehousing_details)

-- Create Table
DROP TABLE IF EXISTS inventories.warehousing_details CASCADE;
CREATE TABLE inventories.warehousing_details (
  warehousing_id varchar(10) NOT NULL check (warehousing_id ~* '^WH-[0-9]{7}$'),
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  ordering_id varchar(10) NOT NULL check (ordering_id ~* '^PO-[0-9]{7}$'),
  warehousing_quantity integer NOT NULL DEFAULT 0 check (warehousing_quantity >= 0),
  return_quantity integer NOT NULL DEFAULT 0 check (return_quantity >= 0),
  unit_price numeric NOT NULL DEFAULT 0.00 check (unit_price >= 0),
  estimate_profit_rate numeric NOT NULL DEFAULT 0.00 check (estimate_profit_rate >= 0),
  site_id varchar(30) NOT NULL check (LENGTH(site_id) >= 1),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.warehousing_details IS '入荷明細';

-- Set Column Comment
COMMENT ON COLUMN inventories.warehousing_details.warehousing_id IS '入荷番号';
COMMENT ON COLUMN inventories.warehousing_details.product_id IS '商品ID';
COMMENT ON COLUMN inventories.warehousing_details.ordering_id IS '発注番号';
COMMENT ON COLUMN inventories.warehousing_details.warehousing_quantity IS '入庫数量';
COMMENT ON COLUMN inventories.warehousing_details.return_quantity IS '返品数量';
COMMENT ON COLUMN inventories.warehousing_details.unit_price IS '単価';
COMMENT ON COLUMN inventories.warehousing_details.estimate_profit_rate IS '想定利益率';
COMMENT ON COLUMN inventories.warehousing_details.site_id IS '倉庫ID';
COMMENT ON COLUMN inventories.warehousing_details.created_at IS '作成日時';
COMMENT ON COLUMN inventories.warehousing_details.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.warehousing_details.created_by IS '作成者';
COMMENT ON COLUMN inventories.warehousing_details.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.warehousing_details ADD PRIMARY KEY (
  warehousing_id,
  product_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.warehousing_details
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.warehousing_details_audit();
CREATE OR REPLACE FUNCTION inventories.warehousing_details_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.warehousing_id || '-' || OLD.product_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.warehousing_id || '-' || NEW.product_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.warehousing_id || '-' || NEW.product_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.warehousing_details
  FOR EACH ROW
EXECUTE PROCEDURE inventories.warehousing_details_audit();
