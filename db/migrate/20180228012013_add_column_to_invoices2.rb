class AddColumnToInvoices2 < ActiveRecord::Migration
  def change
    add_column :invoices, :c_qbupdate, :date
    add_column :invoices, :c_qbcreate, :date
  end
end
