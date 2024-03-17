-- operation_afert_create_tables

-- 41.売掛金修正指示(correct_receivable_instructions)

-- Set FK Constraint
ALTER TABLE inventories.correct_receivable_instructions DROP CONSTRAINT IF EXISTS correct_receivable_instructions_foreignKey_1;
ALTER TABLE inventories.correct_receivable_instructions ADD CONSTRAINT correct_receivable_instructions_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);

ALTER TABLE inventories.correct_receivable_instructions DROP CONSTRAINT IF EXISTS correct_receivable_instructions_foreignKey_2;
ALTER TABLE inventories.correct_receivable_instructions ADD CONSTRAINT correct_receivable_instructions_foreignKey_2 FOREIGN KEY (
  billing_id
) REFERENCES inventories.bills (
  billing_id
);
