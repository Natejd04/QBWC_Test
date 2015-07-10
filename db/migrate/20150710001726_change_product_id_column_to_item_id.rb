class ChangeProductIdColumnToItemId < ActiveRecord::Migration
  def change
      rename_column :line_items, :product_id,  :item_id 
  end
end
