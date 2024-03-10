-- operation_afert_create_tables

-- 5.企業送付先(company_destinations)

-- Set FK Constraint
ALTER TABLE inventories.company_destinations ADD CONSTRAINT company_destinations_foreignKey_1 FOREIGN KEY (
  costomer_id
) REFERENCES inventories.costomers (
  costomer_id
) ON DELETE CASCADE ON UPDATE CASCADE;
