class AddColumnToItems < ActiveRecord::Migration
  def change
    add_column :items, :account_id, :integer
  end
end
