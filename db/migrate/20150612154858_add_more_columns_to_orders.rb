class AddMoreColumnsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :c_class, :string
    add_column :orders, :c_ship1, :string
    add_column :orders, :c_ship2, :string
    add_column :orders, :c_shipcity, :string
    add_column :orders, :c_shipstate, :string
    add_column :orders, :c_shippostal, :string
    add_column :orders, :c_shipcountry, :string
    add_column :orders, :c_invoiced, :string
    add_column :orders, :c_closed, :string
  end
end
