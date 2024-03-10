DROP FUNCTION IF EXISTS inventories.month_summaries_es_pre_process() CASCADE;

DROP FUNCTION IF EXISTS inventories.month_summaries_pre_process() CASCADE;

DROP FUNCTION IF EXISTS inventories.current_summaries_pre_process() CASCADE;

ALTER TABLE inventories.inventory_histories DROP CONSTRAINT IF EXISTS inventory_histories_taransaction_type_check;

DROP FUNCTION IF EXISTS inventories.inventory_histories_pre_process() CASCADE;
