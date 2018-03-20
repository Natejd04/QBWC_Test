class DeleteNChangeColumnsOnLineItems < ActiveRecord::Migration
  def change
  	remove_column :line_items, :invoice_id
  	remove_column :line_items, :product_name
  	remove_column :line_items, :site_name
  	remove_column :line_items, :site_id
  	add_column :line_items, :site_id, :integer
  end
end
