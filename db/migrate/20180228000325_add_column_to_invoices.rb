class AddColumnToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :c_editseq, :string
  end
end
