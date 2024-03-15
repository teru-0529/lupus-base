-- operation_afert_create_tables

-- 27.入荷返品指示(warehousing_return_instructions)

-- Set FK Constraint
ALTER TABLE inventories.warehousing_return_instructions DROP CONSTRAINT IF EXISTS warehousing_return_instructions_foreignKey_1;
ALTER TABLE inventories.warehousing_return_instructions ADD CONSTRAINT warehousing_return_instructions_foreignKey_1 FOREIGN KEY (
  warehousing_id,
  ordering_id,
  product_id
) REFERENCES inventories.warehousing_details (
  warehousing_id,
  ordering_id,
  product_id
);

ALTER TABLE inventories.warehousing_return_instructions DROP CONSTRAINT IF EXISTS warehousing_return_instructions_foreignKey_2;
ALTER TABLE inventories.warehousing_return_instructions ADD CONSTRAINT warehousing_return_instructions_foreignKey_2 FOREIGN KEY (
  payment_id
) REFERENCES inventories.payments (
  payment_id
);

ALTER TABLE inventories.warehousing_return_instructions DROP CONSTRAINT IF EXISTS warehousing_return_instructions_foreignKey_3;
ALTER TABLE inventories.warehousing_return_instructions ADD CONSTRAINT warehousing_return_instructions_foreignKey_3 FOREIGN KEY (
  site_id
) REFERENCES inventories.inventory_sites (
  site_id
);
