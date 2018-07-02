class AddColumnToLineItemsInvoice < ActiveRecord::Migration
  def change
    add_column :line_items, :invoice_id, :integer
  end
end
