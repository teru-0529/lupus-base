DROP FUNCTION IF EXISTS inventories.products_registration_post_process() CASCADE;

ALTER TABLE inventories.suppliers DROP CONSTRAINT IF EXISTS suppliers_order_policy_check;

DROP FUNCTION IF EXISTS inventories.exist_dealing_bank() CASCADE;

DROP VIEW IF EXISTS inventories.view_company_destinations;
