class CreateAddColumnsToOrders5s < ActiveRecord::Migration
 def change
    add_column :orders, :qbcreate, :date
    add_column :orders, :qbupdate, :date
  end
end
