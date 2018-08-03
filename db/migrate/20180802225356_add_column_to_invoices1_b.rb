class AddColumnToInvoices1B < ActiveRecord::Migration
  def change
  	add_column :invoices, :to_email, :boolean
  end
end
