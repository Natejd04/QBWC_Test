class AddTxnToLineItems < ActiveRecord::Migration
  def change
  	add_column :line_items, :txn_id, :string
  end
end
