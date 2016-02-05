class AddDecimalToBills6 < ActiveRecord::Migration
  def change
  	change_column :bills, :amount_due, :float
  end
end
