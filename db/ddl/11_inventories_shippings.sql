-- operation_afert_create_tables

-- 36.出荷(shippings)

-- Set FK Constraint
ALTER TABLE inventories.shippings DROP CONSTRAINT IF EXISTS shippings_foreignKey_1;
ALTER TABLE inventories.shippings ADD CONSTRAINT shippings_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);

ALTER TABLE inventories.shippings DROP CONSTRAINT IF EXISTS shippings_foreignKey_2;
ALTER TABLE inventories.shippings ADD CONSTRAINT shippings_foreignKey_2 FOREIGN KEY (
  billing_id
) REFERENCES inventories.bills (
  billing_id
);
