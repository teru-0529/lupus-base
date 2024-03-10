DROP TABLE IF EXISTS inventories.inventory_sites CASCADE;
DROP TABLE IF EXISTS inventories.products CASCADE;
DROP TABLE IF EXISTS inventories.company_destinations CASCADE;
DROP TABLE IF EXISTS inventories.suppliers CASCADE;
DROP TABLE IF EXISTS inventories.costomers CASCADE;
DROP TABLE IF EXISTS inventories.dealing_banks CASCADE;
DROP TABLE IF EXISTS inventories.companies CASCADE;

DROP FUNCTION IF EXISTS inventories.inventory_sites_audit();
DROP FUNCTION IF EXISTS inventories.products_audit();
DROP FUNCTION IF EXISTS inventories.company_destinations_audit();
DROP FUNCTION IF EXISTS inventories.suppliers_audit();
DROP FUNCTION IF EXISTS inventories.costomers_audit();
DROP FUNCTION IF EXISTS inventories.dealing_banks_audit();
DROP FUNCTION IF EXISTS inventories.companies_audit();
