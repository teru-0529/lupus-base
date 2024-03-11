-- operation_afert_create_tables

-- 8.月次在庫サマリ＿倉庫別(month_inventory_summaries_every_site)

-- Set FK Constraint
ALTER TABLE inventories.month_inventory_summaries_every_site DROP CONSTRAINT IF EXISTS month_inventory_summaries_every_site_foreignKey_1;
ALTER TABLE inventories.month_inventory_summaries_every_site ADD CONSTRAINT month_inventory_summaries_every_site_foreignKey_1 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);

ALTER TABLE inventories.month_inventory_summaries_every_site DROP CONSTRAINT IF EXISTS month_inventory_summaries_every_site_foreignKey_2;
ALTER TABLE inventories.month_inventory_summaries_every_site ADD CONSTRAINT month_inventory_summaries_every_site_foreignKey_2 FOREIGN KEY (
  site_id
) REFERENCES inventories.inventory_sites (
  site_id
);
