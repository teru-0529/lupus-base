-- 更新区分
DROP TYPE IF EXISTS operation_type;
CREATE TYPE operation_type AS enum (
  'INSERT',
  'UPDATE',
  'DELETE'
);

-- 業務日付区分
DROP TYPE IF EXISTS business_date_type;
CREATE TYPE business_date_type AS enum (
  'BASE'
);

-- オペレーション履歴
DROP TABLE IF EXISTS operation_histories CASCADE;
CREATE TABLE operation_histories (
  operated_at timestamp NOT NULL DEFAULT current_timestamp,
  operated_by varchar(58),
  schema_name text NOT NULL,
  table_name text NOT NULL,
  table_key text NOT NULL,
  operation_type operation_type NOT NULL
);

COMMENT ON TABLE operation_histories IS 'オペレーション履歴';
COMMENT ON COLUMN operation_histories.operated_at IS 'オペレーション日時';
COMMENT ON COLUMN operation_histories.operated_by IS 'トレースID';
COMMENT ON COLUMN operation_histories.schema_name IS 'スキーマ';
COMMENT ON COLUMN operation_histories.table_name IS 'テーブル';
COMMENT ON COLUMN operation_histories.table_key IS 'プライマリキー';
COMMENT ON COLUMN operation_histories.operation_type IS '更新区分';

-- 業務日付
DROP TABLE IF EXISTS business_date CASCADE;
CREATE TABLE business_date (
  business_date_type business_date_type NOT NULL ,
  present_date date NOT NULL
);

COMMENT ON TABLE business_date IS '業務日付';
COMMENT ON COLUMN business_date.business_date_type IS '業務日付区分';
COMMENT ON COLUMN business_date.present_date IS '現在日付';
ALTER TABLE business_date ADD PRIMARY KEY (
  business_date_type
);

-- 業務日付の取得
CREATE OR REPLACE FUNCTION get_business_date() RETURNS date AS $$
  BEGIN
  RETURN(SELECT present_date FROM business_date WHERE business_date_type = 'BASE');
END;
$$ LANGUAGE plpgsql;

-- 初期データ(システム日付)登録
INSERT INTO business_date VALUES ('BASE', CURRENT_TIMESTAMP);

-- 更新日時の設定
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN
  -- 更新日時
  NEW.updated_at := now();
  return NEW;
END;
$$ LANGUAGE plpgsql;
