-- operation_afert_create_tables

-- 23.発注キャンセル指示(order_cancel_instructions)

-- Set FK Constraint
ALTER TABLE inventories.order_cancel_instructions DROP CONSTRAINT IF EXISTS order_cancel_instructions_foreignKey_1;
ALTER TABLE inventories.order_cancel_instructions ADD CONSTRAINT order_cancel_instructions_foreignKey_1 FOREIGN KEY (
  ordering_id,
  product_id
) REFERENCES inventories.ordering_details (
  ordering_id,
  product_id
);
