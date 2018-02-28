class ChangeInvoiceColumnName < ActiveRecord::Migration
  def change
  	rename_column :invoices, :c_sonumber, :c_invoicenumber
  end
end
