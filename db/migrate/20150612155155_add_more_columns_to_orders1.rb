class AddMoreColumnsToOrders1 < ActiveRecord::Migration
  def change
    add_column :orders, :c_template, :string
  end
end
