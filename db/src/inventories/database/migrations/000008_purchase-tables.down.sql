DROP TABLE IF EXISTS inventories.payment_instructions CASCADE;
DROP TABLE IF EXISTS inventories.payment_confirm_instructions CASCADE;
DROP TABLE IF EXISTS inventories.order_arrival_change_instructions CASCADE;
DROP TABLE IF EXISTS inventories.order_cancel_instructions CASCADE;

DROP FUNCTION IF EXISTS inventories.payment_instructions_audit();
DROP FUNCTION IF EXISTS inventories.payment_confirm_instructions_audit();
DROP FUNCTION IF EXISTS inventories.order_arrival_change_instructions_audit();
DROP FUNCTION IF EXISTS inventories.order_cancel_instructions_audit();


DROP TABLE IF EXISTS inventories.warehousing_details CASCADE;
DROP TABLE IF EXISTS inventories.warehousings CASCADE;
DROP TABLE IF EXISTS inventories.ordering_details CASCADE;
DROP TABLE IF EXISTS inventories.orderings CASCADE;

DROP FUNCTION IF EXISTS inventories.warehousing_details_audit();
DROP FUNCTION IF EXISTS inventories.warehousings_audit();
DROP FUNCTION IF EXISTS inventories.ordering_details_audit();
DROP FUNCTION IF EXISTS inventories.orderings_audit();


DROP TABLE IF EXISTS inventories.payable_histories CASCADE;
DROP TABLE IF EXISTS inventories.current_accounts_payables CASCADE;
DROP TABLE IF EXISTS inventories.month_accounts_payables CASCADE;
DROP TABLE IF EXISTS inventories.payments CASCADE;

DROP FUNCTION IF EXISTS inventories.payable_histories_audit();
DROP FUNCTION IF EXISTS inventories.current_accounts_payables_audit();
DROP FUNCTION IF EXISTS inventories.month_accounts_payables_audit();
DROP FUNCTION IF EXISTS inventories.payments_audit();
