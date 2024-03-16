DROP FUNCTION IF EXISTS inventories.upsert_accounts_receivables() CASCADE;
DROP FUNCTION IF EXISTS inventories.receivable_histories_pre_process() CASCADE;
ALTER TABLE inventories.receivable_histories DROP CONSTRAINT IF EXISTS receivable_histories_receivable_type_check;
DROP FUNCTION IF EXISTS inventories.current_receivables_pre_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.month_receivables_pre_process() CASCADE;

DROP FUNCTION IF EXISTS inventories.apply_deposit_from_deposit() CASCADE;
DROP FUNCTION IF EXISTS inventories.deposits_pre_process() CASCADE;
ALTER TABLE inventories.bills DROP CONSTRAINT IF EXISTS amount_confirmed_date_check;
ALTER TABLE inventories.bills DROP CONSTRAINT IF EXISTS deposit_limit_date_check;
DROP FUNCTION IF EXISTS inventories.upsert_bills_for_cutoff_date() CASCADE;
DROP FUNCTION IF EXISTS inventories.apply_deposit_from_bill() CASCADE;
DROP FUNCTION IF EXISTS inventories.bills_pre_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.apply_deposit() CASCADE;

-- シーケンス
DROP SEQUENCE IF EXISTS inventories.billing_no_seed;
DROP SEQUENCE IF EXISTS inventories.deposit_no_seed;
DROP SEQUENCE IF EXISTS inventories.receiving_no_seed;
DROP SEQUENCE IF EXISTS inventories.shipping_no_seed;
