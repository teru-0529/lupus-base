-- operation_afert_create_tables

-- 16.月次買掛金サマリ(month_accounts_payables)

-- Set FK Constraint
ALTER TABLE inventories.month_accounts_payables DROP CONSTRAINT IF EXISTS month_accounts_payables_foreignKey_1;
ALTER TABLE inventories.month_accounts_payables ADD CONSTRAINT month_accounts_payables_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.suppliers (
  supplier_id
);
