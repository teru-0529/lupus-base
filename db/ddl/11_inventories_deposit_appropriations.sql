-- operation_afert_create_tables

-- 42.入金充当(deposit_appropriations)

-- Set FK Constraint
ALTER TABLE inventories.deposit_appropriations DROP CONSTRAINT IF EXISTS deposit_appropriations_foreignKey_1;
ALTER TABLE inventories.deposit_appropriations ADD CONSTRAINT deposit_appropriations_foreignKey_1 FOREIGN KEY (
  billing_id
) REFERENCES inventories.bills (
  billing_id
);

ALTER TABLE inventories.deposit_appropriations DROP CONSTRAINT IF EXISTS deposit_appropriations_foreignKey_2;
ALTER TABLE inventories.deposit_appropriations ADD CONSTRAINT deposit_appropriations_foreignKey_2 FOREIGN KEY (
  deposit_id
) REFERENCES inventories.deposits (
  deposit_id
);
