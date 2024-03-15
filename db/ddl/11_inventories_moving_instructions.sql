-- operation_afert_create_tables

-- 13.倉庫移動指示(moving_instructions)

-- Set FK Constraint
ALTER TABLE inventories.moving_instructions DROP CONSTRAINT IF EXISTS moving_instructions_foreignKey_1;
ALTER TABLE inventories.moving_instructions ADD CONSTRAINT moving_instructions_foreignKey_1 FOREIGN KEY (
  site_id_from
) REFERENCES inventories.inventory_sites (
  site_id
);

ALTER TABLE inventories.moving_instructions DROP CONSTRAINT IF EXISTS moving_instructions_foreignKey_2;
ALTER TABLE inventories.moving_instructions ADD CONSTRAINT moving_instructions_foreignKey_2 FOREIGN KEY (
  site_id_to
) REFERENCES inventories.inventory_sites (
  site_id
);

ALTER TABLE inventories.moving_instructions DROP CONSTRAINT IF EXISTS moving_instructions_foreignKey_3;
ALTER TABLE inventories.moving_instructions ADD CONSTRAINT moving_instructions_foreignKey_3 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);
