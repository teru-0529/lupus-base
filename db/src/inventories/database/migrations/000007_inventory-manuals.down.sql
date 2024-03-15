DROP FUNCTION IF EXISTS inventories.month_summaries_es_pre_process() CASCADE;

DROP FUNCTION IF EXISTS inventories.month_summaries_pre_process() CASCADE;

DROP FUNCTION IF EXISTS inventories.current_summaries_pre_process() CASCADE;

ALTER TABLE inventories.inventory_histories DROP CONSTRAINT IF EXISTS inventory_histories_inventory_type_check;

DROP FUNCTION IF EXISTS inventories.inventory_histories_pre_process() CASCADE;

DROP FUNCTION IF EXISTS inventories.upsert_inventory_summaries() CASCADE;

DROP FUNCTION IF EXISTS inventories.insert_move_inventory_history() CASCADE;

DROP FUNCTION IF EXISTS inventories.correct_inventory_instruction_pre_process() CASCADE;

DROP FUNCTION IF EXISTS inventories.insert_correct_inventory_history() CASCADE;
