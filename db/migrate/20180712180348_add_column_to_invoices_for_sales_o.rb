class AddColumnToInvoicesForSalesO < ActiveRecord::Migration
  def change
  	add_column :invoices, :sales_order_txn, :string
  	add_column :invoices, :sales_order_ref, :string
  end
end
