-- operation_afert_create_tables

-- 9.月次在庫サマリ(month_inventory_summaries)

-- Set FK Constraint
ALTER TABLE inventories.month_inventory_summaries DROP CONSTRAINT IF EXISTS month_inventory_summaries_foreignKey_1;
ALTER TABLE inventories.month_inventory_summaries ADD CONSTRAINT month_inventory_summaries_foreignKey_1 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);
