-- operation_afert_create_tables

-- 14.雑入出庫指示(other_inventory_instructions)

-- Set FK Constraint
ALTER TABLE inventories.other_inventory_instructions DROP CONSTRAINT IF EXISTS other_inventory_instructions_foreignKey_1;
ALTER TABLE inventories.other_inventory_instructions ADD CONSTRAINT other_inventory_instructions_foreignKey_1 FOREIGN KEY (
  site_id
) REFERENCES inventories.inventory_sites (
  site_id
);

ALTER TABLE inventories.other_inventory_instructions DROP CONSTRAINT IF EXISTS other_inventory_instructions_foreignKey_2;
ALTER TABLE inventories.other_inventory_instructions ADD CONSTRAINT other_inventory_instructions_foreignKey_2 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);
