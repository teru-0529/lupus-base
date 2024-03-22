-- Enum Type DDL

-- 取引状況
DROP TYPE IF EXISTS inventories.dealing_status;
CREATE TYPE inventories.dealing_status AS enum (
  'READY',
  'ACTIVE',
  'STOP_DEALING'
);

-- 発注方針
DROP TYPE IF EXISTS inventories.order_policy;
CREATE TYPE inventories.order_policy AS enum (
  'WEEKLY',
  'AS_NEEDED'
);

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

-- 買掛変動種類
DROP TYPE IF EXISTS inventories.payable_type;
CREATE TYPE inventories.payable_type AS enum (
  'PURCHASE',
  'PURCHASE_RETURN',
  'PAYMENT',
  'OTHER'
);

-- 支払状況
DROP TYPE IF EXISTS inventories.payment_status;
CREATE TYPE inventories.payment_status AS enum (
  'TO_BE_DETERMINED',
  'CONFIRMED',
  'COMPLETED'
);

-- 売掛変動種類
DROP TYPE IF EXISTS inventories.receivable_type;
CREATE TYPE inventories.receivable_type AS enum (
  'SELES',
  'SALES_RETURN',
  'DEPOSIT',
  'OTHER'
);

-- 請求状況
DROP TYPE IF EXISTS inventories.billing_status;
CREATE TYPE inventories.billing_status AS enum (
  'TO_BE_DETERMINED',
  'CONFIRMED',
  'PART_OF_DEPOSITED',
  'COMPLETED'
);

-- 曜日
DROP TYPE IF EXISTS inventories.week;
CREATE TYPE inventories.week AS enum (
  'SUN',
  'MON',
  'TUE',
  'WED',
  'THU',
  'FRI',
  'SAT'
);

-- 商品入荷状況
DROP TYPE IF EXISTS inventories.product_shipping_situation;
CREATE TYPE inventories.product_shipping_situation AS enum (
  'IN_STOCK',
  'ON_INSPECT',
  'ORDERING',
  'ORDER_PREPARING'
);

-- 倉庫種別
DROP TYPE IF EXISTS inventories.site_type;
CREATE TYPE inventories.site_type AS enum (
  'ALLOWABLE',
  'INSPECT',
  'KEEP'
);

