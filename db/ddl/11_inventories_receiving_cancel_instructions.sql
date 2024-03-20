-- operation_afert_create_tables

-- 38.受注キャンセル指示(receiving_cancel_instructions)

-- Set FK Constraint
ALTER TABLE inventories.receiving_cancel_instructions DROP CONSTRAINT IF EXISTS receiving_cancel_instructions_foreignKey_1;
ALTER TABLE inventories.receiving_cancel_instructions ADD CONSTRAINT receiving_cancel_instructions_foreignKey_1 FOREIGN KEY (
  receiving_id
) REFERENCES inventories.receivings (
  receiving_id
);
