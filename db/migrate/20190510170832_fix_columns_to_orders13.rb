class FixColumnsToOrders13 < ActiveRecord::Migration
  def change
  	remove_column :orders, :Amazon_DF_Cust_Order
  	add_column :orders, :amazon_df_cust_order, :string
  end
end
