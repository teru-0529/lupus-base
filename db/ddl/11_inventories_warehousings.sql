-- operation_afert_create_tables

-- 21.入荷(warehousings)

-- Set FK Constraint
ALTER TABLE inventories.warehousings DROP CONSTRAINT IF EXISTS warehousings_foreignKey_1;
ALTER TABLE inventories.warehousings ADD CONSTRAINT warehousings_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.suppliers (
  supplier_id
);

ALTER TABLE inventories.warehousings DROP CONSTRAINT IF EXISTS warehousings_foreignKey_2;
ALTER TABLE inventories.warehousings ADD CONSTRAINT warehousings_foreignKey_2 FOREIGN KEY (
  payment_id
) REFERENCES inventories.payments (
  payment_id
);
