-- is_master_table=false

-- 40.出荷返品指示(shipping_return_instructions)

-- Create Table
DROP TABLE IF EXISTS inventories.shipping_return_instructions CASCADE;
CREATE TABLE inventories.shipping_return_instructions (
  return_instruction_no serial NOT NULL,
  business_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  operator_id varchar(8) NOT NULL check (operator_id ~* '^P[0-9]{7}$'),
  instruction_cause text,
  sipping_id varchar(10) NOT NULL check (sipping_id ~* '^SP-[0-9]{7}$'),
  receiving_id varchar(10) NOT NULL check (receiving_id ~* '^RO-[0-9]{7}$'),
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  site_id varchar(30) NOT NULL check (LENGTH(site_id) >= 1),
  quantity integer NOT NULL DEFAULT 0 check (quantity >= 0),
  selling_price numeric NOT NULL check (selling_price >= 0),
  cost_price numeric NOT NULL check (cost_price >= 0),
  cut_off_date date NOT NULL,
  deposit_limit_date date NOT NULL,
  billing_id varchar(10) NOT NULL check (billing_id ~* '^BL-[0-9]{7}$'),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.shipping_return_instructions IS '出荷返品指示';

-- Set Column Comment
COMMENT ON COLUMN inventories.shipping_return_instructions.return_instruction_no IS '返品指示No';
COMMENT ON COLUMN inventories.shipping_return_instructions.business_date IS '業務取引日付';
COMMENT ON COLUMN inventories.shipping_return_instructions.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.shipping_return_instructions.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.shipping_return_instructions.instruction_cause IS '指示目的';
COMMENT ON COLUMN inventories.shipping_return_instructions.sipping_id IS '出荷番号';
COMMENT ON COLUMN inventories.shipping_return_instructions.receiving_id IS '受注番号';
COMMENT ON COLUMN inventories.shipping_return_instructions.product_id IS '商品ID';
COMMENT ON COLUMN inventories.shipping_return_instructions.site_id IS '倉庫ID';
COMMENT ON COLUMN inventories.shipping_return_instructions.quantity IS '数量';
COMMENT ON COLUMN inventories.shipping_return_instructions.selling_price IS '売価';
COMMENT ON COLUMN inventories.shipping_return_instructions.cost_price IS '原価';
COMMENT ON COLUMN inventories.shipping_return_instructions.cut_off_date IS '締日付';
COMMENT ON COLUMN inventories.shipping_return_instructions.deposit_limit_date IS '入金期限日付';
COMMENT ON COLUMN inventories.shipping_return_instructions.billing_id IS '請求番号';
COMMENT ON COLUMN inventories.shipping_return_instructions.created_at IS '作成日時';
COMMENT ON COLUMN inventories.shipping_return_instructions.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.shipping_return_instructions.created_by IS '作成者';
COMMENT ON COLUMN inventories.shipping_return_instructions.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.shipping_return_instructions ADD PRIMARY KEY (
  return_instruction_no
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.shipping_return_instructions
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.shipping_return_instructions_audit();
CREATE OR REPLACE FUNCTION inventories.shipping_return_instructions_audit() RETURNS TRIGGER AS $$
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
  ON inventories.shipping_return_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.shipping_return_instructions_audit();
