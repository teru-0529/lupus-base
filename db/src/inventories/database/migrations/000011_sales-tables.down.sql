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
