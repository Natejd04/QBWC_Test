class AddColumnToOrders3 < ActiveRecord::Migration
  def change
    add_column :orders, :invoice_number, :string
  end
end
