class ChangeAccountColumn < ActiveRecord::Migration
  def change
  	remove_column :accounts, :type
  	add_column :accounts, :account_type, :string
  end
end
