class AddDecimalToBills4 < ActiveRecord::Migration
  def change
  	change_column :bills, :amount_due, :decimal, :precision => 8, :scale => 2
  end
end
