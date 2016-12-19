class AddDecimalToBills3 < ActiveRecord::Migration
  	def change
     change_column :bills, :amount_due, :integer, :precision => 8, :scale => 2
    end
end
