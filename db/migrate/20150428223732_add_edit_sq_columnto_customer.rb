class AddEditSqColumntoCustomer < ActiveRecord::Migration
  def change
      add_column :customers, :edit_sq, :string
  end
end
