DROP FUNCTION IF EXISTS inventories.correct_payable_instructions_post_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.correct_payable_instructions_pre_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.shipping_return_instructions_post_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.shipping_return_instructions_pre_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.update_billing_comfirm_date() CASCADE;
DROP FUNCTION IF EXISTS inventories.update_receiving_cancel_quantity() CASCADE;

DROP FUNCTION IF EXISTS inventories.shipping_post_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.shipping_details_pre_process() CASCADE;
ALTER TABLE inventories.shipping_details DROP CONSTRAINT IF EXISTS shipping_details_return_quantity_check;
DROP FUNCTION IF EXISTS inventories.prices_for_shipping() CASCADE;
DROP FUNCTION IF EXISTS inventories.shippings_pre_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.is_before_freeze_deposit_amounts() CASCADE;
DROP FUNCTION IF EXISTS inventories.costomer_id_for_shippings() CASCADE;

DROP FUNCTION IF EXISTS inventories.receiving_details_pre_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.selling_price_for_receivings() CASCADE;
DROP FUNCTION IF EXISTS inventories.receivings_pre_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.costomer_id_for_receivings() CASCADE;

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
