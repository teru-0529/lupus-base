-- operation_afert_create_tables

-- 25.支払金額確定指示(payment_confirm_instructions)

-- Set FK Constraint
ALTER TABLE inventories.payment_confirm_instructions DROP CONSTRAINT IF EXISTS payment_confirm_instructions_foreignKey_1;
ALTER TABLE inventories.payment_confirm_instructions ADD CONSTRAINT payment_confirm_instructions_foreignKey_1 FOREIGN KEY (
  payment_id
) REFERENCES inventories.payments (
  payment_id
);
