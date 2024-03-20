-- operation_afert_create_tables

-- 35.受注明細(receiving_details)

-- Set FK Constraint
ALTER TABLE inventories.receiving_details DROP CONSTRAINT IF EXISTS receiving_details_foreignKey_1;
ALTER TABLE inventories.receiving_details ADD CONSTRAINT receiving_details_foreignKey_1 FOREIGN KEY (
  receiving_id
) REFERENCES inventories.receivings (
  receiving_id
) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE inventories.receiving_details DROP CONSTRAINT IF EXISTS receiving_details_foreignKey_2;
ALTER TABLE inventories.receiving_details ADD CONSTRAINT receiving_details_foreignKey_2 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);
