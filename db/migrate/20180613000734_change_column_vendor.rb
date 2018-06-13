class ChangeColumnVendor < ActiveRecord::Migration
  def change
  	remove_column :vendors, :contact_name
  	remove_column :vendors, :contact_value
  	add_column :vendors, :f_name, :string
  	add_column :vendors, :l_name, :string
  	add_column :vendors, :email, :string
  end
end
