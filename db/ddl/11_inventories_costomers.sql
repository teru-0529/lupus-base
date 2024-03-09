-- operation_afert_create_tables

-- 3.得意先(costomers)

-- Set FK Constraint
ALTER TABLE inventories.costomers ADD CONSTRAINT costomers_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.companies (
  company_id
) ON DELETE CASCADE ON UPDATE CASCADE;
