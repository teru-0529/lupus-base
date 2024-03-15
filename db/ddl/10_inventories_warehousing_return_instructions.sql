-- is_master_table=false

-- 27.入荷返品指示(warehousing_return_instructions)

-- Create Table
DROP TABLE IF EXISTS inventories.warehousing_return_instructions CASCADE;
CREATE TABLE inventories.warehousing_return_instructions (
  return_instruction_no serial NOT NULL,
  business_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  instruction_cause text,
  warehousing_id varchar(10) NOT NULL check (warehousing_id ~* '^WH-[0-9]{7}$'),
  ordering_id varchar(10) NOT NULL check (ordering_id ~* '^PO-[0-9]{7}$'),
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  quantity integer NOT NULL DEFAULT 0 check (quantity >= 0),
  unit_price numeric NOT NULL DEFAULT 0.00 check (unit_price >= 0),
  cut_off_date date NOT NULL,
  payment_limit_date date NOT NULL,
  payment_id varchar(10) NOT NULL check (payment_id ~* '^PM-[0-9]{7}$'),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.warehousing_return_instructions IS '入荷返品指示';

-- Set Column Comment
COMMENT ON COLUMN inventories.warehousing_return_instructions.return_instruction_no IS '返品指示No';
COMMENT ON COLUMN inventories.warehousing_return_instructions.business_date IS '業務取引日付';
COMMENT ON COLUMN inventories.warehousing_return_instructions.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.warehousing_return_instructions.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.warehousing_return_instructions.instruction_cause IS '指示目的';
COMMENT ON COLUMN inventories.warehousing_return_instructions.warehousing_id IS '入荷番号';
COMMENT ON COLUMN inventories.warehousing_return_instructions.ordering_id IS '発注番号';
COMMENT ON COLUMN inventories.warehousing_return_instructions.product_id IS '商品ID';
COMMENT ON COLUMN inventories.warehousing_return_instructions.quantity IS '数量';
COMMENT ON COLUMN inventories.warehousing_return_instructions.unit_price IS '単価';
COMMENT ON COLUMN inventories.warehousing_return_instructions.cut_off_date IS '締日付';
COMMENT ON COLUMN inventories.warehousing_return_instructions.payment_limit_date IS '支払期限日付';
COMMENT ON COLUMN inventories.warehousing_return_instructions.payment_id IS '支払番号';
COMMENT ON COLUMN inventories.warehousing_return_instructions.created_at IS '作成日時';
COMMENT ON COLUMN inventories.warehousing_return_instructions.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.warehousing_return_instructions.created_by IS '作成者';
COMMENT ON COLUMN inventories.warehousing_return_instructions.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.warehousing_return_instructions ADD PRIMARY KEY (
  return_instruction_no
);

-- create index
CREATE INDEX idx_warehousing_return_instructions_1 ON inventories.warehousing_return_instructions (
  warehousing_id,
  ordering_id,
  product_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.warehousing_return_instructions
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.warehousing_return_instructions_audit();
CREATE OR REPLACE FUNCTION inventories.warehousing_return_instructions_audit() RETURNS TRIGGER AS $$
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
  ON inventories.warehousing_return_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.warehousing_return_instructions_audit();
