class AddDecimalToBills2 < ActiveRecord::Migration
  def change
      change_column :bills, :amount_due, :decimal
  end
end
