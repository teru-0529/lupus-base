-- operation_afert_create_tables

-- 15.支払(payments)

-- Set FK Constraint
ALTER TABLE inventories.payments ADD CONSTRAINT payments_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.suppliers (
  supplier_id
);
