-- is_master_table=true

-- 7.倉庫(inventory_sites)

-- Create Table
DROP TABLE IF EXISTS inventories.inventory_sites CASCADE;
CREATE TABLE inventories.inventory_sites (
  site_id varchar(30) NOT NULL check (LENGTH(site_id) >= 1),
  manage_pic varchar(8) NOT NULL check (manage_pic ~* '^P[0-9]{7}$'),
  site_type inventories.site_type NOT NULL,
  note text,
  created_at timestamp NOT NULL DEFAULT current_timestamp,
  updated_at timestamp NOT NULL DEFAULT current_timestamp,
  created_by varchar(58),
  updated_by varchar(58)
);

-- Set Table Comment
COMMENT ON TABLE inventories.inventory_sites IS '倉庫';

-- Set Column Comment
COMMENT ON COLUMN inventories.inventory_sites.site_id IS '倉庫ID';
COMMENT ON COLUMN inventories.inventory_sites.manage_pic IS '管理担当者ID';
COMMENT ON COLUMN inventories.inventory_sites.site_type IS '倉庫種別';
COMMENT ON COLUMN inventories.inventory_sites.note IS '備考';
COMMENT ON COLUMN inventories.inventory_sites.created_at IS '作成日時';
COMMENT ON COLUMN inventories.inventory_sites.updated_at IS '更新日時';
COMMENT ON COLUMN inventories.inventory_sites.created_by IS '作成者';
COMMENT ON COLUMN inventories.inventory_sites.updated_by IS '更新者';

-- Set PK Constraint
ALTER TABLE inventories.inventory_sites ADD PRIMARY KEY (
  site_id
);

-- Create 'set_update_at' Trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE
  ON inventories.inventory_sites
  FOR EACH ROW
EXECUTE PROCEDURE set_updated_at();

-- Create 'append_history' Function
DROP FUNCTION IF EXISTS inventories.inventory_sites_audit();
CREATE OR REPLACE FUNCTION inventories.inventory_sites_audit() RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'DELETE') THEN
    INSERT INTO operation_histories(schema_name, table_name, operation_type, table_key)
    SELECT TG_TABLE_SCHEMA, TG_TABLE_NAME, 'DELETE', OLD.site_id;
  ELSIF (TG_OP = 'UPDATE') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'UPDATE', NEW.site_id;
  ELSIF (TG_OP = 'INSERT') THEN
    INSERT INTO operation_histories(operated_by, schema_name, table_name, operation_type, table_key)
    SELECT NEW.updated_by, TG_TABLE_SCHEMA, TG_TABLE_NAME, 'INSERT', NEW.site_id;
  END IF;
  RETURN null;
END;
$$ LANGUAGE plpgsql;

-- Create 'audit' Trigger
CREATE TRIGGER audit
  AFTER INSERT OR UPDATE OR DELETE
  ON inventories.inventory_sites
  FOR EACH ROW
EXECUTE PROCEDURE inventories.inventory_sites_audit();
