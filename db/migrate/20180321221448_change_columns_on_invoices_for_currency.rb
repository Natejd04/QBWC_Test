class ChangeColumnsOnInvoicesForCurrency < ActiveRecord::Migration
  def change
  	remove_column :invoices, :exchange_rate
  	add_column :invoices, :exchange_rate, :decimal 
  end
end
