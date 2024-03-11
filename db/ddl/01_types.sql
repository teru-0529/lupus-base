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
DROP TYPE IF EXISTS taransaction_type;
CREATE TYPE taransaction_type AS enum (
  'MOVE_WAREHOUSEMENT',
  'PURCHASE',
  'SALES_RETURN',
  'MOVE_SHIPPMENT',
  'SELES',
  'ORDER_RETURN',
  'OTHER'
);

