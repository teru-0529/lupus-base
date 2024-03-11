DROP TABLE IF EXISTS inventories.other_inventory_instructions CASCADE;
DROP TABLE IF EXISTS inventories.moving_instructions CASCADE;
DROP TABLE IF EXISTS inventories.inventory_histories CASCADE;
DROP TABLE IF EXISTS inventories.current_inventory_summaries CASCADE;
DROP TABLE IF EXISTS inventories.current_inventory_summaries_every_site CASCADE;
DROP TABLE IF EXISTS inventories.month_inventory_summaries CASCADE;
DROP TABLE IF EXISTS inventories.month_inventory_summaries_every_site CASCADE;

DROP FUNCTION IF EXISTS inventories.other_inventory_instructions_audit();
DROP FUNCTION IF EXISTS inventories.moving_instructions_audit();
DROP FUNCTION IF EXISTS inventories.inventory_histories_audit();
DROP FUNCTION IF EXISTS inventories.current_inventory_summaries_audit();
DROP FUNCTION IF EXISTS inventories.current_inventory_summaries_every_site_audit();
DROP FUNCTION IF EXISTS inventories.month_inventory_summaries_audit();
DROP FUNCTION IF EXISTS inventories.month_inventory_summaries_every_site_audit();
