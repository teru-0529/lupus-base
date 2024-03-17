DROP TABLE IF EXISTS inventories.correct_receivable_instructions CASCADE;
DROP TABLE IF EXISTS inventories.shipping_return_instructions CASCADE;
DROP TABLE IF EXISTS inventories.billing_confirm_instructions CASCADE;
DROP TABLE IF EXISTS inventories.receiving_cancel_instructions CASCADE;

DROP FUNCTION IF EXISTS inventories.correct_receivable_instructions_audit();
DROP FUNCTION IF EXISTS inventories.shipping_return_instructions_audit();
DROP FUNCTION IF EXISTS inventories.billing_confirm_instructions_audit();
DROP FUNCTION IF EXISTS inventories.receiving_cancel_instructions_audit();

DROP TABLE IF EXISTS inventories.shipping_details CASCADE;
DROP TABLE IF EXISTS inventories.shippings CASCADE;
DROP TABLE IF EXISTS inventories.receiving_details CASCADE;
DROP TABLE IF EXISTS inventories.receivings CASCADE;

DROP FUNCTION IF EXISTS inventories.shipping_details_audit();
DROP FUNCTION IF EXISTS inventories.shippings_audit();
DROP FUNCTION IF EXISTS inventories.receiving_details_audit();
DROP FUNCTION IF EXISTS inventories.receivings_audit();

DROP TABLE IF EXISTS inventories.receivable_histories CASCADE;
DROP TABLE IF EXISTS inventories.current_accounts_receivables CASCADE;
DROP TABLE IF EXISTS inventories.month_accounts_receivables CASCADE;
DROP TABLE IF EXISTS inventories.deposits CASCADE;
DROP TABLE IF EXISTS inventories.bills CASCADE;

DROP FUNCTION IF EXISTS inventories.receivable_histories_audit();
DROP FUNCTION IF EXISTS inventories.current_accounts_receivables_audit();
DROP FUNCTION IF EXISTS inventories.month_accounts_receivables_audit();
DROP FUNCTION IF EXISTS inventories.deposits_audit();
DROP FUNCTION IF EXISTS inventories.bills_audit();
