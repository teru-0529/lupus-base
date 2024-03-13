-- operation_afert_create_tables

-- 19.発注(orderings)

-- Set FK Constraint
ALTER TABLE inventories.orderings DROP CONSTRAINT IF EXISTS orderings_foreignKey_1;
ALTER TABLE inventories.orderings ADD CONSTRAINT orderings_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.suppliers (
  supplier_id
);
