class ChangeInvoiceColumnEmailed < ActiveRecord::Migration
  def change
  	rename_column :invoices, :emailed, :datetime
  end
end
