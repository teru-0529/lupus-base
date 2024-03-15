DROP FUNCTION IF EXISTS inventories.execute_payment() CASCADE;
DROP FUNCTION IF EXISTS inventories.update_payment_comfirm_date() CASCADE;
DROP FUNCTION IF EXISTS inventories.update_order_estimate_arrive_date() CASCADE;
DROP FUNCTION IF EXISTS inventories.update_order_cancel_quantity() CASCADE;

DROP FUNCTION IF EXISTS inventories.warehousing_post_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.warehousing_details_pre_process() CASCADE;
ALTER TABLE inventories.warehousing_details DROP CONSTRAINT IF EXISTS warehousing_details_return_quantity_check;
DROP FUNCTION IF EXISTS inventories.warehousings_pre_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.is_before_freeze_paymant_amounts() CASCADE;
DROP FUNCTION IF EXISTS inventories.supplier_id_for_warehousings() CASCADE;

DROP FUNCTION IF EXISTS inventories.ordering_details_pre_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.is_after_arrival_date() CASCADE;
ALTER TABLE inventories.ordering_details DROP CONSTRAINT IF EXISTS ordering_details_supplier_id_check;
DROP FUNCTION IF EXISTS inventories.cost_price_for_orders() CASCADE;
DROP FUNCTION IF EXISTS inventories.orderings_pre_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.supplier_id_for_orderings() CASCADE;

DROP FUNCTION IF EXISTS inventories.upsert_accounts_payables() CASCADE;
DROP FUNCTION IF EXISTS inventories.payable_histories_pre_process() CASCADE;
ALTER TABLE inventories.payable_histories DROP CONSTRAINT IF EXISTS payable_histories_payable_type_check;
DROP FUNCTION IF EXISTS inventories.current_payables_pre_process() CASCADE;
DROP FUNCTION IF EXISTS inventories.upsert_payments_for_cutoff_date() CASCADE;
DROP FUNCTION IF EXISTS inventories.month_payables_pre_process() CASCADE;

ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS payment_limit_date_check;
ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS amount_confirmed_date_check;
ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS payment_date_check;

DROP FUNCTION IF EXISTS inventories.payments_pre_process() CASCADE;

-- シーケンス
DROP SEQUENCE IF EXISTS inventories.warehousing_no_seed;
DROP SEQUENCE IF EXISTS inventories.ordering_no_seed;
DROP SEQUENCE IF EXISTS inventories.payment_no_seed;
