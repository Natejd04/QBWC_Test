class AddColumnToLineComments < ActiveRecord::Migration
  def change
    add_column :comments, :sales_receipt_id, :integer
  end
end
