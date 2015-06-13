class AddColumnToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :qty, :integer
  end
end
