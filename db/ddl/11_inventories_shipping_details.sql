-- operation_afert_create_tables

-- 37.出荷明細(shipping_details)

-- Set FK Constraint
ALTER TABLE inventories.shipping_details DROP CONSTRAINT IF EXISTS shipping_details_foreignKey_1;
ALTER TABLE inventories.shipping_details ADD CONSTRAINT shipping_details_foreignKey_1 FOREIGN KEY (
  sipping_id
) REFERENCES inventories.shippings (
  sipping_id
) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE inventories.shipping_details DROP CONSTRAINT IF EXISTS shipping_details_foreignKey_2;
ALTER TABLE inventories.shipping_details ADD CONSTRAINT shipping_details_foreignKey_2 FOREIGN KEY (
  receiving_id,
  product_id
) REFERENCES inventories.receiving_details (
  receiving_id,
  product_id
);

ALTER TABLE inventories.shipping_details DROP CONSTRAINT IF EXISTS shipping_details_foreignKey_3;
ALTER TABLE inventories.shipping_details ADD CONSTRAINT shipping_details_foreignKey_3 FOREIGN KEY (
  site_id
) REFERENCES inventories.inventory_sites (
  site_id
);
