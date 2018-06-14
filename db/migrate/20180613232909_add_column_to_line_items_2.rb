class AddColumnToLineItems2 < ActiveRecord::Migration
  def change
    add_column :line_items, :sales_receipt_id, :integer
  end
end
