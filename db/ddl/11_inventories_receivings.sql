-- operation_afert_create_tables

-- 34.受注(receivings)

-- Set FK Constraint
ALTER TABLE inventories.receivings DROP CONSTRAINT IF EXISTS receivings_foreignKey_1;
ALTER TABLE inventories.receivings ADD CONSTRAINT receivings_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);
