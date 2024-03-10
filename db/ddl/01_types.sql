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

