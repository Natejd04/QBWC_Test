class FixColumnInvoices1 < ActiveRecord::Migration
  def change
  	remove_column :invoices, :datetime
  	add_column :invoices, :emailed, :datetime
  end
end
