class AddColumnToOrders11 < ActiveRecord::Migration
  def change
  	add_column :orders, :Amazon_DF_Cust_Order, :string
  	
  end
end
