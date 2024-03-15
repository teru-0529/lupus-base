-- operation_afert_create_tables

-- 28.買掛金修正指示(correct_payable_instructions)

-- Set FK Constraint
ALTER TABLE inventories.correct_payable_instructions DROP CONSTRAINT IF EXISTS correct_payable_instructions_foreignKey_1;
ALTER TABLE inventories.correct_payable_instructions ADD CONSTRAINT correct_payable_instructions_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.suppliers (
  supplier_id
);

ALTER TABLE inventories.correct_payable_instructions DROP CONSTRAINT IF EXISTS correct_payable_instructions_foreignKey_2;
ALTER TABLE inventories.correct_payable_instructions ADD CONSTRAINT correct_payable_instructions_foreignKey_2 FOREIGN KEY (
  payment_id
) REFERENCES inventories.payments (
  payment_id
);
