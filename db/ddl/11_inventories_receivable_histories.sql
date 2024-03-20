-- operation_afert_create_tables

-- 33.売掛変動履歴(receivable_histories)

-- Set FK Constraint
ALTER TABLE inventories.receivable_histories DROP CONSTRAINT IF EXISTS receivable_histories_foreignKey_1;
ALTER TABLE inventories.receivable_histories ADD CONSTRAINT receivable_histories_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);

ALTER TABLE inventories.receivable_histories DROP CONSTRAINT IF EXISTS receivable_histories_foreignKey_2;
ALTER TABLE inventories.receivable_histories ADD CONSTRAINT receivable_histories_foreignKey_2 FOREIGN KEY (
  billing_id
) REFERENCES inventories.bills (
  billing_id
);

ALTER TABLE inventories.receivable_histories DROP CONSTRAINT IF EXISTS receivable_histories_foreignKey_3;
ALTER TABLE inventories.receivable_histories ADD CONSTRAINT receivable_histories_foreignKey_3 FOREIGN KEY (
  deposit_id
) REFERENCES inventories.deposits (
  deposit_id
);
