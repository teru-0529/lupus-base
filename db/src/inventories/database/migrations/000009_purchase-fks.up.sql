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
  paymant_id
) REFERENCES inventories.payments (
  paymant_id
);
