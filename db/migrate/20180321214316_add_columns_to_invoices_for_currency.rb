class AddColumnsToInvoicesForCurrency < ActiveRecord::Migration
  def change
  	add_column :invoices, :currency_ref, :string
  	add_column :invoices, :exchange_rate, :integer
  end
end
