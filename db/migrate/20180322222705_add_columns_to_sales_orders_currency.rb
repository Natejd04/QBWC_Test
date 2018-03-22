class AddColumnsToSalesOrdersCurrency < ActiveRecord::Migration
  def change
  	add_column :orders, :currency_ref, :string
  	add_column :orders, :exchange_rate, :integer
  end
end
