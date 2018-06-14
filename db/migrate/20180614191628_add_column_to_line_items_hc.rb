class AddColumnToLineItemsHc < ActiveRecord::Migration
  def change
    add_column :line_items, :homecurrency_amount, :float
  end
end
