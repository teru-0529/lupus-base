DROP FUNCTION IF EXISTS inventories.upsert_accounts_payables() CASCADE;
DROP FUNCTION IF EXISTS inventories.payable_histories_pre_process() CASCADE;
ALTER TABLE inventories.payable_histories DROP CONSTRAINT IF EXISTS payable_histories_payable_type_check;

DROP FUNCTION IF EXISTS inventories.current_payables_pre_process() CASCADE;

DROP FUNCTION IF EXISTS inventories.month_payables_pre_process() CASCADE;

ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS deposit_date_check;
ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS amount_confirmed_date_check;
ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS payment_date_check;

DROP FUNCTION IF EXISTS inventories.payments_pre_process() CASCADE;

-- シーケンス
DROP SEQUENCE IF EXISTS inventories.warehousing_no_seed;
DROP SEQUENCE IF EXISTS inventories.ordering_no_seed;
DROP SEQUENCE IF EXISTS inventories.payment_no_seed;
