class CreateSiteInventories < ActiveRecord::Migration
  def change
    create_table :site_inventories do |t|
      t.string :item_id
      t.string :site_id
      t.string :qty
      t.string :qty_so

      t.timestamps null: false
    end
  end
end
