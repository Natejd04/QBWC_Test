class AddDecimalToBills < ActiveRecord::Migration
   def change
      change_column :bills, :amount_due, :integer
  end
end
