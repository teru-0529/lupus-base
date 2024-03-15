-- operation_afert_create_tables

-- 20.発注明細(ordering_details)

-- Set FK Constraint
ALTER TABLE inventories.ordering_details DROP CONSTRAINT IF EXISTS ordering_details_foreignKey_1;
ALTER TABLE inventories.ordering_details ADD CONSTRAINT ordering_details_foreignKey_1 FOREIGN KEY (
  ordering_id
) REFERENCES inventories.orderings (
  ordering_id
) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE inventories.ordering_details DROP CONSTRAINT IF EXISTS ordering_details_foreignKey_2;
ALTER TABLE inventories.ordering_details ADD CONSTRAINT ordering_details_foreignKey_2 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);
