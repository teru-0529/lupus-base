-- operation_afert_create_tables

-- 30.入金(deposits)

-- Set FK Constraint
ALTER TABLE inventories.deposits DROP CONSTRAINT IF EXISTS deposits_foreignKey_1;
ALTER TABLE inventories.deposits ADD CONSTRAINT deposits_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);
