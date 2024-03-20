-- operation_afert_create_tables

-- 32.現在売掛金サマリ(current_accounts_receivables)

-- Set FK Constraint
ALTER TABLE inventories.current_accounts_receivables DROP CONSTRAINT IF EXISTS current_accounts_receivables_foreignKey_1;
ALTER TABLE inventories.current_accounts_receivables ADD CONSTRAINT current_accounts_receivables_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);
