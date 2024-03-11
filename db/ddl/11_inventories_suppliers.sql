-- operation_afert_create_tables

-- 4.仕入先(suppliers)

-- Set FK Constraint
ALTER TABLE inventories.suppliers DROP CONSTRAINT IF EXISTS suppliers_foreignKey_1;
ALTER TABLE inventories.suppliers ADD CONSTRAINT suppliers_foreignKey_1 FOREIGN KEY (
  supplier_id
) REFERENCES inventories.companies (
  company_id
) ON DELETE CASCADE ON UPDATE CASCADE;
