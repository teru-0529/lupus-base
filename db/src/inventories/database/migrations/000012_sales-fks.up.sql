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

-- 34.受注(receivings)

-- Set FK Constraint
ALTER TABLE inventories.receivings DROP CONSTRAINT IF EXISTS receivings_foreignKey_1;
ALTER TABLE inventories.receivings ADD CONSTRAINT receivings_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);

-- 35.受注明細(receiving_details)

-- Set FK Constraint
ALTER TABLE inventories.receiving_details DROP CONSTRAINT IF EXISTS receiving_details_foreignKey_1;
ALTER TABLE inventories.receiving_details ADD CONSTRAINT receiving_details_foreignKey_1 FOREIGN KEY (
  receiving_id
) REFERENCES inventories.receivings (
  receiving_id
) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE inventories.receiving_details DROP CONSTRAINT IF EXISTS receiving_details_foreignKey_2;
ALTER TABLE inventories.receiving_details ADD CONSTRAINT receiving_details_foreignKey_2 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);

-- 36.出荷(shippings)

-- Set FK Constraint
ALTER TABLE inventories.shippings DROP CONSTRAINT IF EXISTS shippings_foreignKey_1;
ALTER TABLE inventories.shippings ADD CONSTRAINT shippings_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);

ALTER TABLE inventories.shippings DROP CONSTRAINT IF EXISTS shippings_foreignKey_2;
ALTER TABLE inventories.shippings ADD CONSTRAINT shippings_foreignKey_2 FOREIGN KEY (
  billing_id
) REFERENCES inventories.bills (
  billing_id
);

-- 37.出荷明細(shipping_details)

-- Set FK Constraint
ALTER TABLE inventories.shipping_details DROP CONSTRAINT IF EXISTS shipping_details_foreignKey_1;
ALTER TABLE inventories.shipping_details ADD CONSTRAINT shipping_details_foreignKey_1 FOREIGN KEY (
  sipping_id
) REFERENCES inventories.shippings (
  sipping_id
) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE inventories.shipping_details DROP CONSTRAINT IF EXISTS shipping_details_foreignKey_2;
ALTER TABLE inventories.shipping_details ADD CONSTRAINT shipping_details_foreignKey_2 FOREIGN KEY (
  receiving_id,
  product_id
) REFERENCES inventories.receiving_details (
  receiving_id,
  product_id
);

ALTER TABLE inventories.shipping_details DROP CONSTRAINT IF EXISTS shipping_details_foreignKey_3;
ALTER TABLE inventories.shipping_details ADD CONSTRAINT shipping_details_foreignKey_3 FOREIGN KEY (
  site_id
) REFERENCES inventories.inventory_sites (
  site_id
);

-- 38.受注キャンセル指示(receiving_cancel_instructions)

-- Set FK Constraint
ALTER TABLE inventories.receiving_cancel_instructions DROP CONSTRAINT IF EXISTS receiving_cancel_instructions_foreignKey_1;
ALTER TABLE inventories.receiving_cancel_instructions ADD CONSTRAINT receiving_cancel_instructions_foreignKey_1 FOREIGN KEY (
  receiving_id
) REFERENCES inventories.receivings (
  receiving_id
);

-- 39.請求金額確定指示(billing_confirm_instructions)

-- Set FK Constraint
ALTER TABLE inventories.billing_confirm_instructions DROP CONSTRAINT IF EXISTS billing_confirm_instructions_foreignKey_1;
ALTER TABLE inventories.billing_confirm_instructions ADD CONSTRAINT billing_confirm_instructions_foreignKey_1 FOREIGN KEY (
  billing_id
) REFERENCES inventories.bills (
  billing_id
);

-- 40.出荷返品指示(shipping_return_instructions)

-- Set FK Constraint
ALTER TABLE inventories.shipping_return_instructions DROP CONSTRAINT IF EXISTS shipping_return_instructions_foreignKey_1;
ALTER TABLE inventories.shipping_return_instructions ADD CONSTRAINT shipping_return_instructions_foreignKey_1 FOREIGN KEY (
  sipping_id,
  receiving_id,
  product_id
) REFERENCES inventories.shipping_details (
  sipping_id,
  receiving_id,
  product_id
);

ALTER TABLE inventories.shipping_return_instructions DROP CONSTRAINT IF EXISTS shipping_return_instructions_foreignKey_2;
ALTER TABLE inventories.shipping_return_instructions ADD CONSTRAINT shipping_return_instructions_foreignKey_2 FOREIGN KEY (
  billing_id
) REFERENCES inventories.bills (
  billing_id
);

ALTER TABLE inventories.shipping_return_instructions DROP CONSTRAINT IF EXISTS shipping_return_instructions_foreignKey_3;
ALTER TABLE inventories.shipping_return_instructions ADD CONSTRAINT shipping_return_instructions_foreignKey_3 FOREIGN KEY (
  site_id
) REFERENCES inventories.inventory_sites (
  site_id
);

-- 41.売掛金修正指示(correct_receivable_instructions)

-- Set FK Constraint
ALTER TABLE inventories.correct_receivable_instructions DROP CONSTRAINT IF EXISTS correct_receivable_instructions_foreignKey_1;
ALTER TABLE inventories.correct_receivable_instructions ADD CONSTRAINT correct_receivable_instructions_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
);

ALTER TABLE inventories.correct_receivable_instructions DROP CONSTRAINT IF EXISTS correct_receivable_instructions_foreignKey_2;
ALTER TABLE inventories.correct_receivable_instructions ADD CONSTRAINT correct_receivable_instructions_foreignKey_2 FOREIGN KEY (
  billing_id
) REFERENCES inventories.bills (
  billing_id
);

-- 42.入金充当(deposit_appropriations)

-- Set FK Constraint
ALTER TABLE inventories.deposit_appropriations DROP CONSTRAINT IF EXISTS deposit_appropriations_foreignKey_1;
ALTER TABLE inventories.deposit_appropriations ADD CONSTRAINT deposit_appropriations_foreignKey_1 FOREIGN KEY (
  billing_id
) REFERENCES inventories.bills (
  billing_id
);

ALTER TABLE inventories.deposit_appropriations DROP CONSTRAINT IF EXISTS deposit_appropriations_foreignKey_2;
ALTER TABLE inventories.deposit_appropriations ADD CONSTRAINT deposit_appropriations_foreignKey_2 FOREIGN KEY (
  deposit_id
) REFERENCES inventories.deposits (
  deposit_id
);
