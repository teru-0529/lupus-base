DROP FUNCTION IF EXISTS inventories.calc_planed_order_date() CASCADE;
DROP FUNCTION IF EXISTS inventories.calc_deposit_deadline() CASCADE;
DROP FUNCTION IF EXISTS inventories.calc_payment_deadline() CASCADE;
DROP FUNCTION IF EXISTS inventories.calc_days_to_arriva() CASCADE;
DROP FUNCTION IF EXISTS inventories.calc_profit_rate_by_selling_price() CASCADE;
DROP FUNCTION IF EXISTS inventories.calc_profit_rate_by_cost_price() CASCADE;
DROP FUNCTION IF EXISTS inventories.selling_price_for_products() CASCADE;
DROP FUNCTION IF EXISTS inventories.cost_price_for_products() CASCADE;
DROP FUNCTION IF EXISTS inventories.supplier_id_for_products() CASCADE;

DROP FUNCTION IF EXISTS inventories.products_pre_process() CASCADE;
ALTER TABLE inventories.suppliers DROP CONSTRAINT IF EXISTS suppliers_order_policy_check;
DROP FUNCTION IF EXISTS inventories.exist_dealing_bank() CASCADE;
DROP VIEW IF EXISTS inventories.view_company_destinations;
DROP FUNCTION IF EXISTS inventories.calc_profit_rate() CASCADE;
