class AddColumnsToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :ship_address, :string
    add_column :customers, :ship_address2, :string
    add_column :customers, :ship_address3, :string
    add_column :customers, :ship_address4, :string
    add_column :customers, :ship_city, :string
    add_column :customers, :ship_state, :string
    add_column :customers, :ship_zip, :integer
  end
end
