-- is_master_table=false

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
