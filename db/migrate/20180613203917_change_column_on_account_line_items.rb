class ChangeColumnOnAccountLineItems < ActiveRecord::Migration
  def change
  	remove_column :account_line_items, :type
  	remove_column :account_line_items, :class
  	add_column :account_line_items, :account_type, :string
 	add_column :account_line_items, :class_name, :string
  end
end
