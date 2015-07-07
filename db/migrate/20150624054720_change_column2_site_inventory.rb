class ChangeColumn2SiteInventory < ActiveRecord::Migration
  def change
    remove_column :site_inventories, :site_id
    remove_column :site_inventories, :item_id
    add_column :site_inventories, :site_id, :integer
    add_column :site_inventories, :item_id, :integer
  end
end
