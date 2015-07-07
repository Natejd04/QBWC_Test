class ChangeColumnInSiteInventoryToInteger < ActiveRecord::Migration
  def change
      remove_column :site_inventories, :qty
      remove_column :site_inventories, :qty_so
      add_column :site_inventories, :qty, :float
      add_column :site_inventories, :qty_so, :float
  end
end
