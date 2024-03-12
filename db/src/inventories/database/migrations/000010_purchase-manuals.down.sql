ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS deposit_date_check;
ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS amount_confirmed_date_check;
ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS payment_date_check;

DROP FUNCTION IF EXISTS inventories.payments_pre_process() CASCADE;

-- シーケンス
DROP SEQUENCE IF EXISTS inventories.warehousing_no_seed;
DROP SEQUENCE IF EXISTS inventories.ordering_no_seed;
DROP SEQUENCE IF EXISTS inventories.payment_no_seed;
