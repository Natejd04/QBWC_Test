class RemoveColumnFromInvoices < ActiveRecord::Migration
  def change
    remove_column :invoices, :c_editseq, :string
  end
end
