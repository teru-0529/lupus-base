-- operation_afert_create_tables

-- 39.請求金額確定指示(billing_confirm_instructions)

-- Set FK Constraint
ALTER TABLE inventories.billing_confirm_instructions DROP CONSTRAINT IF EXISTS billing_confirm_instructions_foreignKey_1;
ALTER TABLE inventories.billing_confirm_instructions ADD CONSTRAINT billing_confirm_instructions_foreignKey_1 FOREIGN KEY (
  billing_id
) REFERENCES inventories.bills (
  billing_id
);
