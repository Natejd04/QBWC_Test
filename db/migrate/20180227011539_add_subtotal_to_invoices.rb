class AddSubtotalToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :c_subtotal, :decimal
  end
end
