DROP TABLE IF EXISTS inventories.payable_histories CASCADE;
DROP TABLE IF EXISTS inventories.current_accounts_payables CASCADE;
DROP TABLE IF EXISTS inventories.month_accounts_payables CASCADE;
DROP TABLE IF EXISTS inventories.payments CASCADE;

DROP FUNCTION IF EXISTS inventories.payable_histories_audit();
DROP FUNCTION IF EXISTS inventories.current_accounts_payables_audit();
DROP FUNCTION IF EXISTS inventories.month_accounts_payables_audit();
DROP FUNCTION IF EXISTS inventories.payments_audit();
