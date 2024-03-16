-- operation_afert_create_tables

-- 31.月次売掛金サマリ(month_accounts_receivables)

-- Set FK Constraint
ALTER TABLE inventories.month_accounts_receivables DROP CONSTRAINT IF EXISTS month_accounts_receivables_foreignKey_1;
ALTER TABLE inventories.month_accounts_receivables ADD CONSTRAINT month_accounts_receivables_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);
