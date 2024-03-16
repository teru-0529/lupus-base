-- Enum Type DDL

-- 売掛変動種類
DROP TYPE IF EXISTS receivable_type;
CREATE TYPE receivable_type AS enum (
  'SELLING',
  'SALES_RETURN',
  'DEPOSIT',
  'OTHER'
);

-- 請求状況
DROP TYPE IF EXISTS billing_status;
CREATE TYPE billing_status AS enum (
  'TO_BE_DETERMINED',
  'CONFIRMED',
  'PART_OF',
  'COMPLETED'
);

-- 曜日
DROP TYPE IF EXISTS week;
CREATE TYPE week AS enum (
  'SUN',
  'MON',
  'TUE',
  'WED',
  'THU',
  'FRI',
  'SAT'
);

-- 商品入荷状況
DROP TYPE IF EXISTS product_shipping_situation;
CREATE TYPE product_shipping_situation AS enum (
  'IN_STOCK',
  'ON_INSPECT',
  'ORDERING',
  'ORDER_PREPARING'
);
