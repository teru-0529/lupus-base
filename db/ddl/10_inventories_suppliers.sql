-- is_master_table=true

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
  order_week_num integer check (1 <= order_week_num AND order_week_num <= 7),
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
COMMENT ON COLUMN inventories.suppliers.order_week_num IS '発注曜日';
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
