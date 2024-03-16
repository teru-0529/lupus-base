-- operation_afert_create_tables

-- 22.入荷明細(warehousing_details)

-- Set FK Constraint
ALTER TABLE inventories.warehousing_details DROP CONSTRAINT IF EXISTS warehousing_details_foreignKey_1;
ALTER TABLE inventories.warehousing_details ADD CONSTRAINT warehousing_details_foreignKey_1 FOREIGN KEY (
  warehousing_id
) REFERENCES inventories.warehousings (
  warehousing_id
) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE inventories.warehousing_details DROP CONSTRAINT IF EXISTS warehousing_details_foreignKey_2;
ALTER TABLE inventories.warehousing_details ADD CONSTRAINT warehousing_details_foreignKey_2 FOREIGN KEY (
  ordering_id,
  product_id
) REFERENCES inventories.ordering_details (
  ordering_id,
  product_id
);

ALTER TABLE inventories.warehousing_details DROP CONSTRAINT IF EXISTS warehousing_details_foreignKey_3;
ALTER TABLE inventories.warehousing_details ADD CONSTRAINT warehousing_details_foreignKey_3 FOREIGN KEY (
  site_id
) REFERENCES inventories.inventory_sites (
  site_id
);
