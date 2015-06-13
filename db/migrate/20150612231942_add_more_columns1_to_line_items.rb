class AddMoreColumns1ToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :amount, :float
  end
end
