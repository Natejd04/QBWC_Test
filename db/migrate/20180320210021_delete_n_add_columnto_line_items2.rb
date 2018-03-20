class DeleteNAddColumntoLineItems2 < ActiveRecord::Migration
  def change
  	remove_column :line_items, :item_id
  	add_column :line_items, :item_id, :integer
  end
end
