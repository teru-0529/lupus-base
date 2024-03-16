DROP TABLE IF EXISTS inventories.deposits CASCADE;
DROP TABLE IF EXISTS inventories.bills CASCADE;

DROP FUNCTION IF EXISTS inventories.deposits_audit();
DROP FUNCTION IF EXISTS inventories.bills_audit();
