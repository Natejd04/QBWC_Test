class ChangeColumnOnLineItems1 < ActiveRecord::Migration
  def change
  	remove_column :line_items, :order_id
  end
end
