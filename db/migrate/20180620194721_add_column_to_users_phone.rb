class AddColumnToUsersPhone < ActiveRecord::Migration
  def change
    add_column :users, :phone, :string
    add_column :users, :locked, :boolean
    add_column :users, :email_frequency, :string    
  end
end
