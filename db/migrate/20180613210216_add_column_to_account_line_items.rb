class AddColumnToAccountLineItems < ActiveRecord::Migration
  def change
    add_column :account_line_items, :memo, :string
  end
end
