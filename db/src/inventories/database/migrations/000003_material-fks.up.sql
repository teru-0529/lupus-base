-- operation_afert_create_tables

-- 2.取引銀行(dealing_banks)

-- Set FK Constraint
ALTER TABLE inventories.dealing_banks DROP CONSTRAINT IF EXISTS dealing_banks_foreignKey_1;
ALTER TABLE inventories.dealing_banks ADD CONSTRAINT dealing_banks_foreignKey_1 FOREIGN KEY (
  company_id
) REFERENCES inventories.companies (
  company_id
) ON DELETE CASCADE ON UPDATE CASCADE;

-- 3.得意先(costomers)

-- Set FK Constraint
ALTER TABLE inventories.costomers DROP CONSTRAINT IF EXISTS costomers_foreignKey_1;
ALTER TABLE inventories.costomers ADD CONSTRAINT costomers_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.companies (
  company_id
) ON DELETE CASCADE ON UPDATE CASCADE;

-- 4.仕入先(suppliers)

-- Set FK Constraint
ALTER TABLE inventories.suppliers DROP CONSTRAINT IF EXISTS suppliers_foreignKey_1;
ALTER TABLE inventories.suppliers ADD CONSTRAINT suppliers_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.companies (
  company_id
) ON DELETE CASCADE ON UPDATE CASCADE;

-- 5.企業送付先(company_destinations)

-- Set FK Constraint
ALTER TABLE inventories.company_destinations DROP CONSTRAINT IF EXISTS company_destinations_foreignKey_1;
ALTER TABLE inventories.company_destinations ADD CONSTRAINT company_destinations_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
) ON DELETE CASCADE ON UPDATE CASCADE;

-- 6.商品(products)

-- Set FK Constraint
ALTER TABLE inventories.products DROP CONSTRAINT IF EXISTS products_foreignKey_1;
ALTER TABLE inventories.products ADD CONSTRAINT products_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.suppliers (
  supplier_id
);
