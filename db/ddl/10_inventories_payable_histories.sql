-- is_master_table=false

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
  paymant_id varchar(10) check (paymant_id ~* '^PM[0-9]{8}$'),
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
COMMENT ON COLUMN inventories.payable_histories.paymant_id IS '支払ID';
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
