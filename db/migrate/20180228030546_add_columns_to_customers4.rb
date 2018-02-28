class AddColumnsToCustomers4 < ActiveRecord::Migration
  def change
    add_column :customers, :qbcreate, :date
    add_column :customers, :qbupdate, :date
  end
end
