class AddColumnToCreditMemos < ActiveRecord::Migration
  def change
    add_column :credit_memos, :c_class, :string
  end
end
