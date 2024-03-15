-- operation_afert_create_tables

-- 11.現在在庫サマリ(current_inventory_summaries)

-- Set FK Constraint
ALTER TABLE inventories.current_inventory_summaries DROP CONSTRAINT IF EXISTS current_inventory_summaries_foreignKey_1;
ALTER TABLE inventories.current_inventory_summaries ADD CONSTRAINT current_inventory_summaries_foreignKey_1 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);
