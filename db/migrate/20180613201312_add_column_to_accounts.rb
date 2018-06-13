class AddColumnToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :sublevel, :integer
  end
end
