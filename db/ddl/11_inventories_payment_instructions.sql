-- operation_afert_create_tables

-- 26.支払指示(payment_instructions)

-- Set FK Constraint
ALTER TABLE inventories.payment_instructions DROP CONSTRAINT IF EXISTS payment_instructions_foreignKey_1;
ALTER TABLE inventories.payment_instructions ADD CONSTRAINT payment_instructions_foreignKey_1 FOREIGN KEY (
  payment_id
) REFERENCES inventories.payments (
  payment_id
);
