-- is_master_table=true

-- 5.企業送付先(company_destinations)

-- Create Table
DROP TABLE IF EXISTS inventories.company_destinations CASCADE;
CREATE TABLE inventories.company_destinations (
  destination_no serial NOT NULL,
  costomer_id varchar(6) NOT NULL check (LENGTH(costomer_id) = 6),
  postalcode varchar(8) check (postalcode ~* '^[0-9]{3}-[0-9]{4}$'),
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
COMMENT ON COLUMN inventories.company_destinations.postalcode IS '郵便番号';
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
