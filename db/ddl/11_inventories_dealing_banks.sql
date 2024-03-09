-- operation_afert_create_tables

-- 2.取引銀行(dealing_banks)

-- Set FK Constraint
ALTER TABLE inventories.dealing_banks ADD CONSTRAINT dealing_banks_foreignKey_1 FOREIGN KEY (
  company_id
) REFERENCES inventories.companies (
  company_id
) ON DELETE CASCADE ON UPDATE CASCADE;
