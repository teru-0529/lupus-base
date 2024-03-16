-- operation_afert_create_tables

-- 29.請求(bills)

-- Set FK Constraint
ALTER TABLE inventories.bills DROP CONSTRAINT IF EXISTS bills_foreignKey_1;
ALTER TABLE inventories.bills ADD CONSTRAINT bills_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);

-- 30.入金(deposits)

-- Set FK Constraint
ALTER TABLE inventories.deposits DROP CONSTRAINT IF EXISTS deposits_foreignKey_1;
ALTER TABLE inventories.deposits ADD CONSTRAINT deposits_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);

-- 31.月次売掛金サマリ(month_accounts_receivables)

-- Set FK Constraint
ALTER TABLE inventories.month_accounts_receivables DROP CONSTRAINT IF EXISTS month_accounts_receivables_foreignKey_1;
ALTER TABLE inventories.month_accounts_receivables ADD CONSTRAINT month_accounts_receivables_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);

-- 32.現在売掛金サマリ(current_accounts_receivables)

-- Set FK Constraint
ALTER TABLE inventories.current_accounts_receivables DROP CONSTRAINT IF EXISTS current_accounts_receivables_foreignKey_1;
ALTER TABLE inventories.current_accounts_receivables ADD CONSTRAINT current_accounts_receivables_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);

-- 33.売掛変動履歴(receivable_histories)

-- Set FK Constraint
ALTER TABLE inventories.receivable_histories DROP CONSTRAINT IF EXISTS receivable_histories_foreignKey_1;
ALTER TABLE inventories.receivable_histories ADD CONSTRAINT receivable_histories_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);

ALTER TABLE inventories.receivable_histories DROP CONSTRAINT IF EXISTS receivable_histories_foreignKey_2;
ALTER TABLE inventories.receivable_histories ADD CONSTRAINT receivable_histories_foreignKey_2 FOREIGN KEY (
  billing_id
) REFERENCES inventories.bills (
  billing_id
);

ALTER TABLE inventories.receivable_histories DROP CONSTRAINT IF EXISTS receivable_histories_foreignKey_3;
ALTER TABLE inventories.receivable_histories ADD CONSTRAINT receivable_histories_foreignKey_3 FOREIGN KEY (
  deposit_id
) REFERENCES inventories.deposits (
  deposit_id
);
