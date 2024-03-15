-- operation_afert_create_tables

-- 6.商品(products)

-- Set FK Constraint
ALTER TABLE inventories.products DROP CONSTRAINT IF EXISTS products_foreignKey_1;
ALTER TABLE inventories.products ADD CONSTRAINT products_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.suppliers (
  supplier_id
);
