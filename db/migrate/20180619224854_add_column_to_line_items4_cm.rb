class AddColumnToLineItems4Cm < ActiveRecord::Migration
  def change
    add_column :line_items, :credit_memo_id, :integer
  end
end
