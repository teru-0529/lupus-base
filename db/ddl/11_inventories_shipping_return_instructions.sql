-- operation_afert_create_tables

-- 40.出荷返品指示(shipping_return_instructions)

-- Set FK Constraint
ALTER TABLE inventories.shipping_return_instructions DROP CONSTRAINT IF EXISTS shipping_return_instructions_foreignKey_1;
ALTER TABLE inventories.shipping_return_instructions ADD CONSTRAINT shipping_return_instructions_foreignKey_1 FOREIGN KEY (
  sipping_id,
  receiving_id,
  product_id
) REFERENCES inventories.shipping_details (
  sipping_id,
  receiving_id,
  product_id
);

ALTER TABLE inventories.shipping_return_instructions DROP CONSTRAINT IF EXISTS shipping_return_instructions_foreignKey_2;
ALTER TABLE inventories.shipping_return_instructions ADD CONSTRAINT shipping_return_instructions_foreignKey_2 FOREIGN KEY (
  billing_id
) REFERENCES inventories.bills (
  billing_id
);

ALTER TABLE inventories.shipping_return_instructions DROP CONSTRAINT IF EXISTS shipping_return_instructions_foreignKey_3;
ALTER TABLE inventories.shipping_return_instructions ADD CONSTRAINT shipping_return_instructions_foreignKey_3 FOREIGN KEY (
  site_id
) REFERENCES inventories.inventory_sites (
  site_id
);
