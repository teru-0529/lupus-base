-- Enum Type DDL

-- 取引状況
DROP TYPE IF EXISTS dealing_status;
CREATE TYPE dealing_status AS enum (
  'READY',
  'ACTIVE',
  'STOP_DEALING'
);

-- 発注方針
DROP TYPE IF EXISTS order_policy;
CREATE TYPE order_policy AS enum (
  'WEEKLY',
  'AS_NEEDED'
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

-- 倉庫種別
DROP TYPE IF EXISTS site_type;
CREATE TYPE site_type AS enum (
  'ALLOWABLE',
  'INSPECT',
  'KEEP'
);

-- Tables DDL

-- 1.企業(companies)

-- Create Table
DROP TABLE IF EXISTS inventories.companies CASCADE;
CREATE TABLE inventories.companies (
  company_id varchar(6) NOT NULL check (LENGTH(company_id) = 6),
  company_name varchar(30),
  postal_code varchar(8) check (postal_code ~* '^[0-9]{3}-[0-9]{4}$'),
  address text,
  phone_no varchar(11) check (phone_no ~* '^[0-9]{9,10}$'),
  fax_no varchar(11) check (fax_no ~* '^[0-9]{9,10}$'),
  note text,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.companies IS '企業';

-- Set Column Comment
COMMENT ON COLUMN inventories.companies.company_id IS '企業ID';
COMMENT ON COLUMN inventories.companies.company_name IS '企業名称';
COMMENT ON COLUMN inventories.companies.postal_code IS '郵便番号';
COMMENT ON COLUMN inventories.companies.address IS '住所';
COMMENT ON COLUMN inventories.companies.phone_no IS '電話番号';
COMMENT ON COLUMN inventories.companies.fax_no IS 'FAX番号';
COMMENT ON COLUMN inventories.companies.note IS '備考';
COMMENT ON COLUMN inventories.companies.created_at IS '作成日時';
COMMENT ON COLUMN inventories.companies.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.companies.created_by IS '作成者';
COMMENT ON COLUMN inventories.companies.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.companies ADD PRIMARY KEY (
  company_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.companies
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.companies_audit();
CREATE OR REPLACE FUNCTION inventories.companies_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.company_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.company_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.company_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.companies
  FOR EACH ROW
EXECUTE PROCEDURE inventories.companies_audit();

-- 2.取引銀行(dealing_banks)

-- Create Table
DROP TABLE IF EXISTS inventories.dealing_banks CASCADE;
CREATE TABLE inventories.dealing_banks (
  company_id varchar(6) NOT NULL check (LENGTH(company_id) = 6),
  bank_code varchar(4) NOT NULL check (bank_code ~* '^[0-9]{4}$'),
  bank_name varchar(30) NOT NULL,
  bank_branch_code varchar(3) NOT NULL check (bank_branch_code ~* '^[0-9]{3}$'),
  bank_account_no varchar(50) NOT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.dealing_banks IS '取引銀行';

-- Set Column Comment
COMMENT ON COLUMN inventories.dealing_banks.company_id IS '企業ID';
COMMENT ON COLUMN inventories.dealing_banks.bank_code IS '銀行コード';
COMMENT ON COLUMN inventories.dealing_banks.bank_name IS '銀行名称';
COMMENT ON COLUMN inventories.dealing_banks.bank_branch_code IS '支店コード';
COMMENT ON COLUMN inventories.dealing_banks.bank_account_no IS '口座番号';
COMMENT ON COLUMN inventories.dealing_banks.created_at IS '作成日時';
COMMENT ON COLUMN inventories.dealing_banks.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.dealing_banks.created_by IS '作成者';
COMMENT ON COLUMN inventories.dealing_banks.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.dealing_banks ADD PRIMARY KEY (
  company_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.dealing_banks
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.dealing_banks_audit();
CREATE OR REPLACE FUNCTION inventories.dealing_banks_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.company_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.company_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.company_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.dealing_banks
  FOR EACH ROW
EXECUTE PROCEDURE inventories.dealing_banks_audit();

-- 3.得意先(costomers)

-- Create Table
DROP TABLE IF EXISTS inventories.costomers CASCADE;
CREATE TABLE inventories.costomers (
  costomer_id varchar(6) NOT NULL check (LENGTH(costomer_id) = 6),
  dealing_status dealing_status NOT NULL DEFAULT 'READY',
  cut_off_day integer NOT NULL DEFAULT 99 check (1 <= cut_off_day AND cut_off_day <= 99),
  month_of_deposit_term integer NOT NULL DEFAULT 1 check (month_of_deposit_term >= 1),
  deposit_day integer NOT NULL DEFAULT 99 check (1 <= deposit_day AND deposit_day <= 99),
  sales_pic varchar(8) check (sales_pic ~* '^P[0-9]{7}$'),
  contact_person varchar(20),
  note text,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.costomers IS '得意先';

-- Set Column Comment
COMMENT ON COLUMN inventories.costomers.costomer_id IS '得意先ID';
COMMENT ON COLUMN inventories.costomers.dealing_status IS '取引状況';
COMMENT ON COLUMN inventories.costomers.cut_off_day IS '締日';
COMMENT ON COLUMN inventories.costomers.month_of_deposit_term IS '入金猶予月数';
COMMENT ON COLUMN inventories.costomers.deposit_day IS '入金期限日';
COMMENT ON COLUMN inventories.costomers.sales_pic IS '営業担当者ID';
COMMENT ON COLUMN inventories.costomers.contact_person IS '相手先担当者';
COMMENT ON COLUMN inventories.costomers.note IS '備考';
COMMENT ON COLUMN inventories.costomers.created_at IS '作成日時';
COMMENT ON COLUMN inventories.costomers.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.costomers.created_by IS '作成者';
COMMENT ON COLUMN inventories.costomers.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.costomers ADD PRIMARY KEY (
  costomer_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.costomers
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.costomers_audit();
CREATE OR REPLACE FUNCTION inventories.costomers_audit() RETURNS TRIGGER AS $$
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
  ON inventories.costomers
  FOR EACH ROW
EXECUTE PROCEDURE inventories.costomers_audit();

-- 4.仕入先(suppliers)

-- Create Table
DROP TABLE IF EXISTS inventories.suppliers CASCADE;
CREATE TABLE inventories.suppliers (
  supplier_id varchar(6) NOT NULL check (LENGTH(supplier_id) = 6),
  dealing_status dealing_status NOT NULL DEFAULT 'READY',
  cut_off_day integer NOT NULL DEFAULT 99 check (1 <= cut_off_day AND cut_off_day <= 99),
  month_of_payment_term integer NOT NULL DEFAULT 1 check (month_of_payment_term >= 1),
  payment_day integer NOT NULL DEFAULT 99 check (1 <= payment_day AND payment_day <= 99),
  purchase_pic varchar(8) check (purchase_pic ~* '^P[0-9]{7}$'),
  contact_person varchar(20),
  order_policy order_policy NOT NULL,
  order_week week,
  days_to_arrive integer NOT NULL check (days_to_arrive >= 1),
  note text,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.suppliers IS '仕入先';

-- Set Column Comment
COMMENT ON COLUMN inventories.suppliers.supplier_id IS '仕入先ID';
COMMENT ON COLUMN inventories.suppliers.dealing_status IS '取引状況';
COMMENT ON COLUMN inventories.suppliers.cut_off_day IS '締日';
COMMENT ON COLUMN inventories.suppliers.month_of_payment_term IS '支払猶予月数';
COMMENT ON COLUMN inventories.suppliers.payment_day IS '支払期限日';
COMMENT ON COLUMN inventories.suppliers.purchase_pic IS '仕入担当者ID';
COMMENT ON COLUMN inventories.suppliers.contact_person IS '相手先担当者';
COMMENT ON COLUMN inventories.suppliers.order_policy IS '発注方針';
COMMENT ON COLUMN inventories.suppliers.order_week IS '発注曜日';
COMMENT ON COLUMN inventories.suppliers.days_to_arrive IS '標準入荷日数';
COMMENT ON COLUMN inventories.suppliers.note IS '備考';
COMMENT ON COLUMN inventories.suppliers.created_at IS '作成日時';
COMMENT ON COLUMN inventories.suppliers.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.suppliers.created_by IS '作成者';
COMMENT ON COLUMN inventories.suppliers.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.suppliers ADD PRIMARY KEY (
  supplier_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.suppliers
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.suppliers_audit();
CREATE OR REPLACE FUNCTION inventories.suppliers_audit() RETURNS TRIGGER AS $$
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
  ON inventories.suppliers
  FOR EACH ROW
EXECUTE PROCEDURE inventories.suppliers_audit();

-- 5.企業送付先(company_destinations)

-- Create Table
DROP TABLE IF EXISTS inventories.company_destinations CASCADE;
CREATE TABLE inventories.company_destinations (
  destination_no serial NOT NULL,
  costomer_id varchar(6) NOT NULL check (LENGTH(costomer_id) = 6),
  postal_code varchar(8) check (postal_code ~* '^[0-9]{3}-[0-9]{4}$'),
  address text,
  phone_no varchar(11) check (phone_no ~* '^[0-9]{9,10}$'),
  fax_no varchar(11) check (fax_no ~* '^[0-9]{9,10}$'),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.company_destinations IS '企業送付先';

-- Set Column Comment
COMMENT ON COLUMN inventories.company_destinations.destination_no IS '送付先No';
COMMENT ON COLUMN inventories.company_destinations.costomer_id IS '得意先ID';
COMMENT ON COLUMN inventories.company_destinations.postal_code IS '郵便番号';
COMMENT ON COLUMN inventories.company_destinations.address IS '住所';
COMMENT ON COLUMN inventories.company_destinations.phone_no IS '電話番号';
COMMENT ON COLUMN inventories.company_destinations.fax_no IS 'FAX番号';
COMMENT ON COLUMN inventories.company_destinations.created_at IS '作成日時';
COMMENT ON COLUMN inventories.company_destinations.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.company_destinations.created_by IS '作成者';
COMMENT ON COLUMN inventories.company_destinations.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.company_destinations ADD PRIMARY KEY (
  destination_no
);

-- create index
CREATE UNIQUE INDEX idx_company_destinations_1 ON inventories.company_destinations (
  costomer_id,
  destination_no
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.company_destinations
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.company_destinations_audit();
CREATE OR REPLACE FUNCTION inventories.company_destinations_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.destination_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.destination_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.destination_no;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.company_destinations
  FOR EACH ROW
EXECUTE PROCEDURE inventories.company_destinations_audit();

-- 6.商品(products)

-- Create Table
DROP TABLE IF EXISTS inventories.products CASCADE;
CREATE TABLE inventories.products (
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  supplier_id varchar(6) NOT NULL check (LENGTH(supplier_id) = 6),
  product_code varchar(30) NOT NULL,
  product_name varchar(30) NOT NULL,
  dealing_status dealing_status NOT NULL DEFAULT 'READY',
  selling_price numeric NOT NULL DEFAULT 0.00 check (selling_price >= 0),
  cost_price numeric NOT NULL DEFAULT 0.00 check (cost_price >= 0),
  standard_profit_rate numeric check (standard_profit_rate >= 0),
  days_to_arrive integer check (days_to_arrive >= 1),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.products IS '商品';

-- Set Column Comment
COMMENT ON COLUMN inventories.products.product_id IS '商品ID';
COMMENT ON COLUMN inventories.products.supplier_id IS '仕入先ID';
COMMENT ON COLUMN inventories.products.product_code IS '仕入れ先商品コード';
COMMENT ON COLUMN inventories.products.product_name IS '商品名称';
COMMENT ON COLUMN inventories.products.dealing_status IS '取引状況';
COMMENT ON COLUMN inventories.products.selling_price IS '売価';
COMMENT ON COLUMN inventories.products.cost_price IS '原価';
COMMENT ON COLUMN inventories.products.standard_profit_rate IS '標準利益率';
COMMENT ON COLUMN inventories.products.days_to_arrive IS '標準入荷日数';
COMMENT ON COLUMN inventories.products.created_at IS '作成日時';
COMMENT ON COLUMN inventories.products.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.products.created_by IS '作成者';
COMMENT ON COLUMN inventories.products.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.products ADD PRIMARY KEY (
  product_id
);

-- Set Unique Constraint
ALTER TABLE inventories.products ADD CONSTRAINT products_unique_1 UNIQUE (
  supplier_id,
  product_code
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.products
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.products_audit();
CREATE OR REPLACE FUNCTION inventories.products_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.product_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.product_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.product_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.products
  FOR EACH ROW
EXECUTE PROCEDURE inventories.products_audit();

-- 7.倉庫(inventory_sites)

-- Create Table
DROP TABLE IF EXISTS inventories.inventory_sites CASCADE;
CREATE TABLE inventories.inventory_sites (
  site_id varchar(30) NOT NULL check (LENGTH(site_id) >= 1),
  manage_pic varchar(8) NOT NULL check (manage_pic ~* '^P[0-9]{7}$'),
  site_type site_type NOT NULL,
  note text,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.inventory_sites IS '倉庫';

-- Set Column Comment
COMMENT ON COLUMN inventories.inventory_sites.site_id IS '倉庫ID';
COMMENT ON COLUMN inventories.inventory_sites.manage_pic IS '管理担当者ID';
COMMENT ON COLUMN inventories.inventory_sites.site_type IS '倉庫種別';
COMMENT ON COLUMN inventories.inventory_sites.note IS '備考';
COMMENT ON COLUMN inventories.inventory_sites.created_at IS '作成日時';
COMMENT ON COLUMN inventories.inventory_sites.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.inventory_sites.created_by IS '作成者';
COMMENT ON COLUMN inventories.inventory_sites.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.inventory_sites ADD PRIMARY KEY (
  site_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.inventory_sites
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.inventory_sites_audit();
CREATE OR REPLACE FUNCTION inventories.inventory_sites_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.site_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.site_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.site_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.inventory_sites
  FOR EACH ROW
EXECUTE PROCEDURE inventories.inventory_sites_audit();
