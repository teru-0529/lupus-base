-- Enum Type DDL

-- 在庫変動種類
DROP TYPE IF EXISTS inventories.inventory_type;
CREATE TYPE inventories.inventory_type AS enum (
  'MOVE_WAREHOUSEMENT',
  'PURCHASE',
  'SALES_RETURN',
  'MOVE_SHIPPMENT',
  'SELES',
  'PURCHASE_RETURN',
  'OTHER'
);

-- Tables DDL

-- 8.月次在庫サマリ＿倉庫別(month_inventory_summaries_every_site)

-- Create Table
DROP TABLE IF EXISTS inventories.month_inventory_summaries_every_site CASCADE;
CREATE TABLE inventories.month_inventory_summaries_every_site (
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  year_month varchar(6) NOT NULL check (year_month ~* '^[12][0-9]{3}(0[1-9]|1[0-2])$'),
  site_id varchar(30) NOT NULL check (LENGTH(site_id) >= 1),
  init_quantity integer NOT NULL DEFAULT 0 check (init_quantity >= 0),
  warehousing_quantity integer NOT NULL DEFAULT 0 check (warehousing_quantity >= 0),
  shipping_quantity integer NOT NULL DEFAULT 0 check (shipping_quantity >= 0),
  present_quantity integer NOT NULL DEFAULT 0 check (present_quantity >= 0),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.month_inventory_summaries_every_site IS '月次在庫サマリ＿倉庫別';

-- Set Column Comment
COMMENT ON COLUMN inventories.month_inventory_summaries_every_site.product_id IS '商品ID';
COMMENT ON COLUMN inventories.month_inventory_summaries_every_site.year_month IS '年月';
COMMENT ON COLUMN inventories.month_inventory_summaries_every_site.site_id IS '倉庫ID';
COMMENT ON COLUMN inventories.month_inventory_summaries_every_site.init_quantity IS '月初数量';
COMMENT ON COLUMN inventories.month_inventory_summaries_every_site.warehousing_quantity IS '入庫数量';
COMMENT ON COLUMN inventories.month_inventory_summaries_every_site.shipping_quantity IS '出庫数量';
COMMENT ON COLUMN inventories.month_inventory_summaries_every_site.present_quantity IS '在庫数量';
COMMENT ON COLUMN inventories.month_inventory_summaries_every_site.created_at IS '作成日時';
COMMENT ON COLUMN inventories.month_inventory_summaries_every_site.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.month_inventory_summaries_every_site.created_by IS '作成者';
COMMENT ON COLUMN inventories.month_inventory_summaries_every_site.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.month_inventory_summaries_every_site ADD PRIMARY KEY (
  product_id,
  year_month,
  site_id
);

-- create index
CREATE UNIQUE INDEX idx_month_inventory_summaries_every_site_1 ON inventories.month_inventory_summaries_every_site (
  product_id,
  site_id,
  year_month
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.month_inventory_summaries_every_site
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.month_inventory_summaries_every_site_audit();
CREATE OR REPLACE FUNCTION inventories.month_inventory_summaries_every_site_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.product_id || '-' || OLD.year_month || '-' || OLD.site_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.product_id || '-' || NEW.year_month || '-' || NEW.site_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.product_id || '-' || NEW.year_month || '-' || NEW.site_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.month_inventory_summaries_every_site
  FOR EACH ROW
EXECUTE PROCEDURE inventories.month_inventory_summaries_every_site_audit();

-- 9.月次在庫サマリ(month_inventory_summaries)

-- Create Table
DROP TABLE IF EXISTS inventories.month_inventory_summaries CASCADE;
CREATE TABLE inventories.month_inventory_summaries (
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  year_month varchar(6) NOT NULL check (year_month ~* '^[12][0-9]{3}(0[1-9]|1[0-2])$'),
  init_quantity integer NOT NULL DEFAULT 0 check (init_quantity >= 0),
  warehousing_quantity integer NOT NULL DEFAULT 0 check (warehousing_quantity >= 0),
    shipping_quantity integer NOT NULL DEFAULT 0 check (shipping_quantity >= 0),
  present_quantity integer NOT NULL DEFAULT 0 check (present_quantity >= 0),
  init_amount numeric NOT NULL DEFAULT 0.00 check (init_amount >= 0),
  warehousing_amount numeric NOT NULL DEFAULT 0.00 check (warehousing_amount >= 0),
  shipping_amount numeric NOT NULL DEFAULT 0.00 check (shipping_amount >= 0),
  present_amount numeric NOT NULL DEFAULT 0.00 check (present_amount >= 0),
  cost_price numeric check (cost_price >= 0),
  estimate_profit_rate numeric check (estimate_profit_rate >= 0),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.month_inventory_summaries IS '月次在庫サマリ';

-- Set Column Comment
COMMENT ON COLUMN inventories.month_inventory_summaries.product_id IS '商品ID';
COMMENT ON COLUMN inventories.month_inventory_summaries.year_month IS '年月';
COMMENT ON COLUMN inventories.month_inventory_summaries.init_quantity IS '月初数量';
COMMENT ON COLUMN inventories.month_inventory_summaries.warehousing_quantity IS '入庫数量';
COMMENT ON COLUMN inventories.month_inventory_summaries.shipping_quantity IS '出庫数量';
COMMENT ON COLUMN inventories.month_inventory_summaries.present_quantity IS '在庫数量';
COMMENT ON COLUMN inventories.month_inventory_summaries.init_amount IS '月初金額';
COMMENT ON COLUMN inventories.month_inventory_summaries.warehousing_amount IS '入庫金額';
COMMENT ON COLUMN inventories.month_inventory_summaries.shipping_amount IS '出庫金額';
COMMENT ON COLUMN inventories.month_inventory_summaries.present_amount IS '在庫金額';
COMMENT ON COLUMN inventories.month_inventory_summaries.cost_price IS '原価';
COMMENT ON COLUMN inventories.month_inventory_summaries.estimate_profit_rate IS '想定利益率';
COMMENT ON COLUMN inventories.month_inventory_summaries.created_at IS '作成日時';
COMMENT ON COLUMN inventories.month_inventory_summaries.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.month_inventory_summaries.created_by IS '作成者';
COMMENT ON COLUMN inventories.month_inventory_summaries.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.month_inventory_summaries ADD PRIMARY KEY (
  product_id,
  year_month
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.month_inventory_summaries
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.month_inventory_summaries_audit();
CREATE OR REPLACE FUNCTION inventories.month_inventory_summaries_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.product_id || '-' || OLD.year_month;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.product_id || '-' || NEW.year_month;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.product_id || '-' || NEW.year_month;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.month_inventory_summaries
  FOR EACH ROW
EXECUTE PROCEDURE inventories.month_inventory_summaries_audit();

-- 10.現在在庫サマリ＿倉庫別(current_inventory_summaries_every_site)

-- Create Table
DROP TABLE IF EXISTS inventories.current_inventory_summaries_every_site CASCADE;
CREATE TABLE inventories.current_inventory_summaries_every_site (
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  site_id varchar(30) NOT NULL check (LENGTH(site_id) >= 1),
  present_quantity integer NOT NULL DEFAULT 0 check (present_quantity >= 0),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.current_inventory_summaries_every_site IS '現在在庫サマリ＿倉庫別';

-- Set Column Comment
COMMENT ON COLUMN inventories.current_inventory_summaries_every_site.product_id IS '商品ID';
COMMENT ON COLUMN inventories.current_inventory_summaries_every_site.site_id IS '倉庫ID';
COMMENT ON COLUMN inventories.current_inventory_summaries_every_site.present_quantity IS '在庫数量';
COMMENT ON COLUMN inventories.current_inventory_summaries_every_site.created_at IS '作成日時';
COMMENT ON COLUMN inventories.current_inventory_summaries_every_site.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.current_inventory_summaries_every_site.created_by IS '作成者';
COMMENT ON COLUMN inventories.current_inventory_summaries_every_site.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.current_inventory_summaries_every_site ADD PRIMARY KEY (
  product_id,
  site_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.current_inventory_summaries_every_site
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.current_inventory_summaries_every_site_audit();
CREATE OR REPLACE FUNCTION inventories.current_inventory_summaries_every_site_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.product_id || '-' || OLD.site_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.product_id || '-' || NEW.site_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.product_id || '-' || NEW.site_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.current_inventory_summaries_every_site
  FOR EACH ROW
EXECUTE PROCEDURE inventories.current_inventory_summaries_every_site_audit();

-- 11.現在在庫サマリ(current_inventory_summaries)

-- Create Table
DROP TABLE IF EXISTS inventories.current_inventory_summaries CASCADE;
CREATE TABLE inventories.current_inventory_summaries (
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  present_quantity integer NOT NULL DEFAULT 0 check (present_quantity >= 0),
  present_amount numeric NOT NULL DEFAULT 0.00 check (present_amount >= 0),
  cost_price numeric check (cost_price >= 0),
  estimate_profit_rate numeric check (estimate_profit_rate >= 0),
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.current_inventory_summaries IS '現在在庫サマリ';

-- Set Column Comment
COMMENT ON COLUMN inventories.current_inventory_summaries.product_id IS '商品ID';
COMMENT ON COLUMN inventories.current_inventory_summaries.present_quantity IS '在庫数量';
COMMENT ON COLUMN inventories.current_inventory_summaries.present_amount IS '在庫金額';
COMMENT ON COLUMN inventories.current_inventory_summaries.cost_price IS '原価';
COMMENT ON COLUMN inventories.current_inventory_summaries.estimate_profit_rate IS '想定利益率';
COMMENT ON COLUMN inventories.current_inventory_summaries.created_at IS '作成日時';
COMMENT ON COLUMN inventories.current_inventory_summaries.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.current_inventory_summaries.created_by IS '作成者';
COMMENT ON COLUMN inventories.current_inventory_summaries.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.current_inventory_summaries ADD PRIMARY KEY (
  product_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.current_inventory_summaries
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.current_inventory_summaries_audit();
CREATE OR REPLACE FUNCTION inventories.current_inventory_summaries_audit() RETURNS TRIGGER AS $$
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
  ON inventories.current_inventory_summaries
  FOR EACH ROW
EXECUTE PROCEDURE inventories.current_inventory_summaries_audit();

-- 12.在庫変動履歴(inventory_histories)

-- Create Table
DROP TABLE IF EXISTS inventories.inventory_histories CASCADE;
CREATE TABLE inventories.inventory_histories (
  inventory_no serial NOT NULL,
  business_date date NOT NULL DEFAULT get_business_date(),
  operation_timestamp timestamp NOT NULL DEFAULT current_timestamp,
  product_id varchar(10) NOT NULL check (LENGTH(product_id) >= 9),
  site_id varchar(30) NOT NULL check (LENGTH(site_id) >= 1),
  variable_quantity integer NOT NULL,
  variable_amount numeric NOT NULL,
  inventory_type inventories.inventory_type NOT NULL,
  tranzaction_no serial NOT NULL,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.inventory_histories IS '在庫変動履歴';

-- Set Column Comment
COMMENT ON COLUMN inventories.inventory_histories.inventory_no IS '在庫変動No';
COMMENT ON COLUMN inventories.inventory_histories.business_date IS '業務取引日付';
COMMENT ON COLUMN inventories.inventory_histories.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.inventory_histories.product_id IS '商品ID';
COMMENT ON COLUMN inventories.inventory_histories.site_id IS '倉庫ID';
COMMENT ON COLUMN inventories.inventory_histories.variable_quantity IS '変動数量';
COMMENT ON COLUMN inventories.inventory_histories.variable_amount IS '変動金額';
COMMENT ON COLUMN inventories.inventory_histories.inventory_type IS '在庫変動種類';
COMMENT ON COLUMN inventories.inventory_histories.tranzaction_no IS '取引管理No';
COMMENT ON COLUMN inventories.inventory_histories.created_at IS '作成日時';
COMMENT ON COLUMN inventories.inventory_histories.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.inventory_histories.created_by IS '作成者';
COMMENT ON COLUMN inventories.inventory_histories.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.inventory_histories ADD PRIMARY KEY (
  inventory_no
);

-- create index
CREATE INDEX idx_inventory_histories_1 ON inventories.inventory_histories (
  product_id,
  business_date,
  operation_timestamp
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.inventory_histories
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.inventory_histories_audit();
CREATE OR REPLACE FUNCTION inventories.inventory_histories_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.inventory_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.inventory_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.inventory_no;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.inventory_histories
  FOR EACH ROW
EXECUTE PROCEDURE inventories.inventory_histories_audit();

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

-- 14.在庫修正指示(correct_inventory_instructions)

-- Create Table
DROP TABLE IF EXISTS inventories.correct_inventory_instructions CASCADE;
CREATE TABLE inventories.correct_inventory_instructions (
  inventory_correct_instruction_no serial NOT NULL,
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
COMMENT ON TABLE inventories.correct_inventory_instructions IS '在庫修正指示';

-- Set Column Comment
COMMENT ON COLUMN inventories.correct_inventory_instructions.inventory_correct_instruction_no IS '在庫修正指示No';
COMMENT ON COLUMN inventories.correct_inventory_instructions.business_date IS '業務取引日付';
COMMENT ON COLUMN inventories.correct_inventory_instructions.operation_timestamp IS '処理日時';
COMMENT ON COLUMN inventories.correct_inventory_instructions.operator_id IS '指示実行者ID';
COMMENT ON COLUMN inventories.correct_inventory_instructions.instruction_cause IS '指示目的';
COMMENT ON COLUMN inventories.correct_inventory_instructions.site_id IS '倉庫ID';
COMMENT ON COLUMN inventories.correct_inventory_instructions.product_id IS '商品ID';
COMMENT ON COLUMN inventories.correct_inventory_instructions.variable_quantity IS '変動数量';
COMMENT ON COLUMN inventories.correct_inventory_instructions.variable_amount IS '変動金額';
COMMENT ON COLUMN inventories.correct_inventory_instructions.created_at IS '作成日時';
COMMENT ON COLUMN inventories.correct_inventory_instructions.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.correct_inventory_instructions.created_by IS '作成者';
COMMENT ON COLUMN inventories.correct_inventory_instructions.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.correct_inventory_instructions ADD PRIMARY KEY (
  inventory_correct_instruction_no
);

-- create index
CREATE INDEX idx_correct_inventory_instructions_1 ON inventories.correct_inventory_instructions (
  product_id,
  business_date,
  operation_timestamp
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.correct_inventory_instructions
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.correct_inventory_instructions_audit();
CREATE OR REPLACE FUNCTION inventories.correct_inventory_instructions_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.inventory_correct_instruction_no;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.inventory_correct_instruction_no;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.inventory_correct_instruction_no;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.correct_inventory_instructions
  FOR EACH ROW
EXECUTE PROCEDURE inventories.correct_inventory_instructions_audit();
