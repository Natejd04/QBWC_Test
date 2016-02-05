class AddDecimalToBills5 < ActiveRecord::Migration
  def change
  	change_column :bills, :amount_due, :numeric
  end
end
