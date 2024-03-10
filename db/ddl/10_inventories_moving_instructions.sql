-- is_master_table=false

-- 13.倉庫移動指示(moving_instructions)

-- Create Table
DROP TABLE IF EXISTS inventories.moving_instructions CASCADE;
CREATE TABLE inventories.moving_instructions (
  move_instruction_no serial NOT NULL,
  business_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  instruction_cause text,
  site_id_from varchar(30) NOT NULL check (LENGTH(site_id_from) >= 1),
  site_id_to varchar(30) NOT NULL check (LENGTH(site_id_to) >= 1),
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  quantity integer NOT NULL DEFAULT 0 check (quantity >= 0),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.moving_instructions IS '倉庫移動指示';

-- Set Column Comment
COMMENT ON COLUMN inventories.moving_instructions.move_instruction_no IS '在庫移動指示No';
COMMENT ON COLUMN inventories.moving_instructions.business_date IS '業務取引日付';
COMMENT ON COLUMN inventories.moving_instructions.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.moving_instructions.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.moving_instructions.instruction_cause IS '指示目的';
COMMENT ON COLUMN inventories.moving_instructions.site_id_from IS '移動元倉庫ID';
COMMENT ON COLUMN inventories.moving_instructions.site_id_to IS '移動先倉庫ID';
COMMENT ON COLUMN inventories.moving_instructions.product_id IS '商品ID';
COMMENT ON COLUMN inventories.moving_instructions.quantity IS '数量';
COMMENT ON COLUMN inventories.moving_instructions.created_at IS '作成日時';
COMMENT ON COLUMN inventories.moving_instructions.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.moving_instructions.created_by IS '作成者';
COMMENT ON COLUMN inventories.moving_instructions.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.moving_instructions ADD PRIMARY KEY (
  move_instruction_no
);

-- create index
CREATE INDEX idx_moving_instructions_1 ON inventories.moving_instructions (
  product_id,
  business_date,
  operation_timestamp
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.moving_instructions
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.moving_instructions_audit();
CREATE OR REPLACE FUNCTION inventories.moving_instructions_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.move_instruction_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.move_instruction_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.move_instruction_no;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.moving_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.moving_instructions_audit();
