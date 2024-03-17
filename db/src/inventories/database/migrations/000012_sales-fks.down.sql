ALTER TABLE inventories.shipping_details DROP CONSTRAINT IF EXISTS shipping_details_foreignKey_1;
ALTER TABLE inventories.shipping_details DROP CONSTRAINT IF EXISTS shipping_details_foreignKey_2;
ALTER TABLE inventories.shipping_details DROP CONSTRAINT IF EXISTS shipping_details_foreignKey_3;
ALTER TABLE inventories.shippings DROP CONSTRAINT IF EXISTS shippings_foreignKey_1;
ALTER TABLE inventories.shippings DROP CONSTRAINT IF EXISTS shippings_foreignKey_2;
ALTER TABLE inventories.receiving_details DROP CONSTRAINT IF EXISTS receiving_details_foreignKey_1;
ALTER TABLE inventories.receiving_details DROP CONSTRAINT IF EXISTS receiving_details_foreignKey_2;
ALTER TABLE inventories.receivings DROP CONSTRAINT IF EXISTS receivings_foreignKey_1;

ALTER TABLE inventories.receivable_histories DROP CONSTRAINT IF EXISTS receivable_histories_foreignKey_1;
ALTER TABLE inventories.receivable_histories DROP CONSTRAINT IF EXISTS receivable_histories_foreignKey_2;
ALTER TABLE inventories.receivable_histories DROP CONSTRAINT IF EXISTS receivable_histories_foreignKey_3;
ALTER TABLE inventories.current_accounts_receivables DROP CONSTRAINT IF EXISTS current_accounts_receivables_foreignKey_1;
ALTER TABLE inventories.month_accounts_receivables DROP CONSTRAINT IF EXISTS month_accounts_receivables_foreignKey_1;
ALTER TABLE inventories.deposits DROP CONSTRAINT IF EXISTS deposits_foreignKey_1;
ALTER TABLE inventories.bills DROP CONSTRAINT IF EXISTS bills_foreignKey_1;
