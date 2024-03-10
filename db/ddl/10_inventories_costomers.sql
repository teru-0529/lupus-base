-- is_master_table=true

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
COMMENT ON COLUMN inventories.costomers.cut_off_day IS '締日付';
COMMENT ON COLUMN inventories.costomers.month_of_deposit_term IS '入金猶予月数';
COMMENT ON COLUMN inventories.costomers.deposit_day IS '入金期限日付';
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
