-- is_master_table=true

-- 1.企業(companies)

-- Create Table
DROP TABLE IF EXISTS inventories.companies CASCADE;
CREATE TABLE inventories.companies (
  company_id varchar(6) NOT NULL check (LENGTH(company_id) = 6),
  company_name varchar(30),
  postalcode varchar(8) check (postalcode ~* '^[0-9]{3}-[0-9]{4}$'),
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
COMMENT ON COLUMN inventories.companies.postalcode IS '郵便番号';
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
