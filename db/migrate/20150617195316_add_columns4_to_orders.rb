class AddColumns4ToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :c_ship3, :string
    add_column :orders, :c_ship4, :string
    add_column :orders, :c_ship5, :string
  end
end
