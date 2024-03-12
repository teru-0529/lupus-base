-- operation_afert_create_tables

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
