ALTER TABLE inventories.correct_inventory_instructions DROP CONSTRAINT IF EXISTS correct_inventory_instructions_foreignKey_1;
ALTER TABLE inventories.correct_inventory_instructions DROP CONSTRAINT IF EXISTS correct_inventory_instructions_foreignKey_2;
ALTER TABLE inventories.moving_instructions DROP CONSTRAINT IF EXISTS moving_instructions_foreignKey_1;
ALTER TABLE inventories.moving_instructions DROP CONSTRAINT IF EXISTS moving_instructions_foreignKey_2;
ALTER TABLE inventories.moving_instructions DROP CONSTRAINT IF EXISTS moving_instructions_foreignKey_3;
ALTER TABLE inventories.inventory_histories DROP CONSTRAINT IF EXISTS inventory_histories_foreignKey_1;
ALTER TABLE inventories.inventory_histories DROP CONSTRAINT IF EXISTS inventory_histories_foreignKey_2;
ALTER TABLE inventories.current_inventory_summaries DROP CONSTRAINT IF EXISTS current_inventory_summaries_foreignKey_1;
ALTER TABLE inventories.current_inventory_summaries_every_site DROP CONSTRAINT IF EXISTS current_inventory_summaries_every_site_foreignKey_1;
ALTER TABLE inventories.current_inventory_summaries_every_site DROP CONSTRAINT IF EXISTS current_inventory_summaries_every_site_foreignKey_2;
ALTER TABLE inventories.month_inventory_summaries DROP CONSTRAINT IF EXISTS month_inventory_summaries_foreignKey_1;
ALTER TABLE inventories.month_inventory_summaries_every_site DROP CONSTRAINT IF EXISTS month_inventory_summaries_every_site_foreignKey_1;
ALTER TABLE inventories.month_inventory_summaries_every_site DROP CONSTRAINT IF EXISTS month_inventory_summaries_every_site_foreignKey_2;
