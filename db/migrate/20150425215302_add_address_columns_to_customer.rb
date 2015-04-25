class AddAddressColumnsToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :address2, :string
    add_column :customers, :city, :string
    add_column :customers, :state, :string
    add_column :customers, :zip, :integer
  end
end
