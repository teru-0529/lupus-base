-- operation_afert_create_tables

-- 29.請求(bills)

-- Set FK Constraint
ALTER TABLE inventories.bills DROP CONSTRAINT IF EXISTS bills_foreignKey_1;
ALTER TABLE inventories.bills ADD CONSTRAINT bills_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);

-- 30.入金(deposits)

-- Set FK Constraint
ALTER TABLE inventories.deposits DROP CONSTRAINT IF EXISTS deposits_foreignKey_1;
ALTER TABLE inventories.deposits ADD CONSTRAINT deposits_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);
