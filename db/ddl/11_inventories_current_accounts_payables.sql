-- operation_afert_create_tables

-- 17.現在買掛金サマリ(current_accounts_payables)

-- Set FK Constraint
ALTER TABLE inventories.current_accounts_payables ADD CONSTRAINT current_accounts_payables_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.suppliers (
  supplier_id
);
