-- operation_afert_create_tables

-- 12.在庫変動履歴(inventory_histories)

-- Set FK Constraint
ALTER TABLE inventories.inventory_histories ADD CONSTRAINT inventory_histories_foreignKey_1 FOREIGN KEY (
  site_id
) REFERENCES inventories.inventory_sites (
  site_id
);

ALTER TABLE inventories.inventory_histories ADD CONSTRAINT inventory_histories_foreignKey_2 FOREIGN KEY (
  product_id
) REFERENCES inventories.products (
  product_id
);
