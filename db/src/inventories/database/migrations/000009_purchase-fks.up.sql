-- operation_afert_create_tables

-- 15.支払(payments)

-- Set FK Constraint
ALTER TABLE inventories.payments DROP CONSTRAINT IF EXISTS payments_foreignKey_1;
ALTER TABLE inventories.payments ADD CONSTRAINT payments_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.suppliers (
  supplier_id
);

-- 16.月次買掛金サマリ(month_accounts_payables)

-- Set FK Constraint
ALTER TABLE inventories.month_accounts_payables DROP CONSTRAINT IF EXISTS month_accounts_payables_foreignKey_1;
ALTER TABLE inventories.month_accounts_payables ADD CONSTRAINT month_accounts_payables_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.suppliers (
  supplier_id
);

-- 17.現在買掛金サマリ(current_accounts_payables)

-- Set FK Constraint
ALTER TABLE inventories.current_accounts_payables DROP CONSTRAINT IF EXISTS current_accounts_payables_foreignKey_1;
ALTER TABLE inventories.current_accounts_payables ADD CONSTRAINT current_accounts_payables_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.suppliers (
  supplier_id
);

-- 18.買掛変動履歴(payable_histories)

-- Set FK Constraint
ALTER TABLE inventories.payable_histories DROP CONSTRAINT IF EXISTS payable_histories_foreignKey_1;
ALTER TABLE inventories.payable_histories ADD CONSTRAINT payable_histories_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.suppliers (
  supplier_id
);

ALTER TABLE inventories.payable_histories DROP CONSTRAINT IF EXISTS payable_histories_foreignKey_2;
ALTER TABLE inventories.payable_histories ADD CONSTRAINT payable_histories_foreignKey_2 FOREIGN KEY (
  payment_id
) REFERENCES inventories.payments (
  payment_id
);

-- 19.発注(orderings)

-- Set FK Constraint
ALTER TABLE inventories.orderings DROP CONSTRAINT IF EXISTS orderings_foreignKey_1;
ALTER TABLE inventories.orderings ADD CONSTRAINT orderings_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.suppliers (
  supplier_id
);

-- 20.発注明細(ordering_details)

-- Set FK Constraint
ALTER TABLE inventories.ordering_details DROP CONSTRAINT IF EXISTS ordering_details_foreignKey_1;
ALTER TABLE inventories.ordering_details ADD CONSTRAINT ordering_details_foreignKey_1 FOREIGN KEY (
  ordering_id
) REFERENCES inventories.orderings (
  ordering_id
) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE inventories.ordering_details DROP CONSTRAINT IF EXISTS ordering_details_foreignKey_2;
ALTER TABLE inventories.ordering_details ADD CONSTRAINT ordering_details_foreignKey_2 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);

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

-- 22.入荷明細(warehousing_details)

-- Set FK Constraint
ALTER TABLE inventories.warehousing_details DROP CONSTRAINT IF EXISTS warehousing_details_foreignKey_1;
ALTER TABLE inventories.warehousing_details ADD CONSTRAINT warehousing_details_foreignKey_1 FOREIGN KEY (
  ordering_id,
  product_id
) REFERENCES inventories.ordering_details (
  ordering_id,
  product_id
);

ALTER TABLE inventories.warehousing_details DROP CONSTRAINT IF EXISTS warehousing_details_foreignKey_2;
ALTER TABLE inventories.warehousing_details ADD CONSTRAINT warehousing_details_foreignKey_2 FOREIGN KEY (
  site_id
) REFERENCES inventories.inventory_sites (
  site_id
);

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

-- 25.支払金額確定指示(payment_confirm_instructions)

-- Set FK Constraint
ALTER TABLE inventories.payment_confirm_instructions DROP CONSTRAINT IF EXISTS payment_confirm_instructions_foreignKey_1;
ALTER TABLE inventories.payment_confirm_instructions ADD CONSTRAINT payment_confirm_instructions_foreignKey_1 FOREIGN KEY (
  payment_id
) REFERENCES inventories.payments (
  payment_id
);

-- 26.支払指示(payment_instructions)

-- Set FK Constraint
ALTER TABLE inventories.payment_instructions DROP CONSTRAINT IF EXISTS payment_instructions_foreignKey_1;
ALTER TABLE inventories.payment_instructions ADD CONSTRAINT payment_instructions_foreignKey_1 FOREIGN KEY (
  payment_id
) REFERENCES inventories.payments (
  payment_id
);
