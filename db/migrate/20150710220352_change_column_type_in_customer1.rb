class ChangeColumnTypeInCustomer1 < ActiveRecord::Migration
  def change
       change_column :customers, :ship_zip, :string
       add_column :customers, :ship_address5, :string
  end
end
