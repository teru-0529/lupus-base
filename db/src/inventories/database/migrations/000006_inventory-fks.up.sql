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

-- 9.月次在庫サマリ(month_inventory_summaries)

-- Set FK Constraint
ALTER TABLE inventories.month_inventory_summaries DROP CONSTRAINT IF EXISTS month_inventory_summaries_foreignKey_1;
ALTER TABLE inventories.month_inventory_summaries ADD CONSTRAINT month_inventory_summaries_foreignKey_1 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);

-- 10.現在在庫サマリ＿倉庫別(current_inventory_summaries_every_site)

-- Set FK Constraint
ALTER TABLE inventories.current_inventory_summaries_every_site DROP CONSTRAINT IF EXISTS current_inventory_summaries_every_site_foreignKey_1;
ALTER TABLE inventories.current_inventory_summaries_every_site ADD CONSTRAINT current_inventory_summaries_every_site_foreignKey_1 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);

ALTER TABLE inventories.current_inventory_summaries_every_site DROP CONSTRAINT IF EXISTS current_inventory_summaries_every_site_foreignKey_2;
ALTER TABLE inventories.current_inventory_summaries_every_site ADD CONSTRAINT current_inventory_summaries_every_site_foreignKey_2 FOREIGN KEY (
  site_id
) REFERENCES inventories.inventory_sites (
  site_id
);

-- 11.現在在庫サマリ(current_inventory_summaries)

-- Set FK Constraint
ALTER TABLE inventories.current_inventory_summaries DROP CONSTRAINT IF EXISTS current_inventory_summaries_foreignKey_1;
ALTER TABLE inventories.current_inventory_summaries ADD CONSTRAINT current_inventory_summaries_foreignKey_1 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);

-- 12.在庫変動履歴(inventory_histories)

-- Set FK Constraint
ALTER TABLE inventories.inventory_histories DROP CONSTRAINT IF EXISTS inventory_histories_foreignKey_1;
ALTER TABLE inventories.inventory_histories ADD CONSTRAINT inventory_histories_foreignKey_1 FOREIGN KEY (
  site_id
) REFERENCES inventories.inventory_sites (
  site_id
);

ALTER TABLE inventories.inventory_histories DROP CONSTRAINT IF EXISTS inventory_histories_foreignKey_2;
ALTER TABLE inventories.inventory_histories ADD CONSTRAINT inventory_histories_foreignKey_2 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);

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

-- 14.在庫修正指示(correct_inventory_instructions)

-- Set FK Constraint
ALTER TABLE inventories.correct_inventory_instructions DROP CONSTRAINT IF EXISTS correct_inventory_instructions_foreignKey_1;
ALTER TABLE inventories.correct_inventory_instructions ADD CONSTRAINT correct_inventory_instructions_foreignKey_1 FOREIGN KEY (
  site_id
) REFERENCES inventories.inventory_sites (
  site_id
);

ALTER TABLE inventories.correct_inventory_instructions DROP CONSTRAINT IF EXISTS correct_inventory_instructions_foreignKey_2;
ALTER TABLE inventories.correct_inventory_instructions ADD CONSTRAINT correct_inventory_instructions_foreignKey_2 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);
