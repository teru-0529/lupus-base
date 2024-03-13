ALTER TABLE inventories.warehousing_details DROP CONSTRAINT IF EXISTS warehousing_details_foreignKey_1;
ALTER TABLE inventories.warehousing_details DROP CONSTRAINT IF EXISTS warehousing_details_foreignKey_2;
ALTER TABLE inventories.warehousings DROP CONSTRAINT IF EXISTS warehousings_foreignKey_1;
ALTER TABLE inventories.warehousings DROP CONSTRAINT IF EXISTS warehousings_foreignKey_2;
ALTER TABLE inventories.ordering_details DROP CONSTRAINT IF EXISTS ordering_details_foreignKey_1;
ALTER TABLE inventories.ordering_details DROP CONSTRAINT IF EXISTS ordering_details_foreignKey_2;
ALTER TABLE inventories.orderings DROP CONSTRAINT IF EXISTS orderings_foreignKey_1;

ALTER TABLE inventories.payable_histories DROP CONSTRAINT IF EXISTS payable_histories_foreignKey_1;
ALTER TABLE inventories.payable_histories DROP CONSTRAINT IF EXISTS payable_histories_foreignKey_2;
ALTER TABLE inventories.current_accounts_payables DROP CONSTRAINT IF EXISTS current_accounts_payables_foreignKey_1;
ALTER TABLE inventories.month_accounts_payables DROP CONSTRAINT IF EXISTS month_accounts_payables_foreignKey_1;
ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS payments_foreignKey_1;
