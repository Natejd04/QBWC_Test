class ChangeColumnNameinItems < ActiveRecord::Migration
  def change
  	remove_column :items, :type
  	add_column :items, :item_type, :string 
  end
end
