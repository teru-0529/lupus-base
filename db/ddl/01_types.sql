-- Enum Type DDL

-- 取引状況
DROP TYPE IF EXISTS dealing_status;
CREATE TYPE dealing_status AS enum (
  'READY',
  'ACTIVE',
  'STOP_DEALING'
);

-- 発注方針
DROP TYPE IF EXISTS order_policy;
CREATE TYPE order_policy AS enum (
  'PERIODICALLY',
  'AS_NEEDED'
);

-- 在庫変動種類
DROP TYPE IF EXISTS inventory_type;
CREATE TYPE inventory_type AS enum (
  'MOVE_WAREHOUSEMENT',
  'PURCHASE',
  'SALES_RETURN',
  'MOVE_SHIPPMENT',
  'SELES',
  'ORDER_RETURN',
  'OTHER'
);

-- 買掛変動種類
DROP TYPE IF EXISTS payable_type;
CREATE TYPE payable_type AS enum (
  'PURCHASE',
  'ORDER_RETURN',
  'PAYMENT',
  'OTHER'
);

-- 支払状況
DROP TYPE IF EXISTS payment_status;
CREATE TYPE payment_status AS enum (
  'TO_BE_DETERMINED',
  'CONFIRMED',
  'COMPLETED'
);

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

