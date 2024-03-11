-- is_master_table=false

-- 14.雑入出庫指示(other_inventory_instructions)

-- Create Table
DROP TABLE IF EXISTS inventories.other_inventory_instructions CASCADE;
CREATE TABLE inventories.other_inventory_instructions (
  other_inventory_instruction_no serial NOT NULL,
  business_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  instruction_cause text,
  site_id varchar(30) NOT NULL check (LENGTH(site_id) >= 1),
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  variable_quantity integer NOT NULL,
  variable_amount numeric NOT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.other_inventory_instructions IS '雑入出庫指示';

-- Set Column Comment
COMMENT ON COLUMN inventories.other_inventory_instructions.other_inventory_instruction_no IS '雑入出庫指示No';
COMMENT ON COLUMN inventories.other_inventory_instructions.business_date IS '業務取引日付';
COMMENT ON COLUMN inventories.other_inventory_instructions.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.other_inventory_instructions.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.other_inventory_instructions.instruction_cause IS '指示目的';
COMMENT ON COLUMN inventories.other_inventory_instructions.site_id IS '倉庫ID';
COMMENT ON COLUMN inventories.other_inventory_instructions.product_id IS '商品ID';
COMMENT ON COLUMN inventories.other_inventory_instructions.variable_quantity IS '変動数量';
COMMENT ON COLUMN inventories.other_inventory_instructions.variable_amount IS '変動金額';
COMMENT ON COLUMN inventories.other_inventory_instructions.created_at IS '作成日時';
COMMENT ON COLUMN inventories.other_inventory_instructions.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.other_inventory_instructions.created_by IS '作成者';
COMMENT ON COLUMN inventories.other_inventory_instructions.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.other_inventory_instructions ADD PRIMARY KEY (
  other_inventory_instruction_no
);

-- create index
CREATE INDEX idx_other_inventory_instructions_1 ON inventories.other_inventory_instructions (
  product_id,
  business_date,
  operation_timestamp
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.other_inventory_instructions
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.other_inventory_instructions_audit();
CREATE OR REPLACE FUNCTION inventories.other_inventory_instructions_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.other_inventory_instruction_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.other_inventory_instruction_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.other_inventory_instruction_no;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.other_inventory_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.other_inventory_instructions_audit();
