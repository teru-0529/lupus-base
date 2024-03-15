-- operation_afert_create_tables

-- 24.発注納期変更指示(order_arrival_change_instructions)

-- Set FK Constraint
ALTER TABLE inventories.order_arrival_change_instructions DROP CONSTRAINT IF EXISTS order_arrival_change_instructions_foreignKey_1;
ALTER TABLE inventories.order_arrival_change_instructions ADD CONSTRAINT order_arrival_change_instructions_foreignKey_1 FOREIGN KEY (
  ordering_id,
  product_id
) REFERENCES inventories.ordering_details (
  ordering_id,
  product_id
);
