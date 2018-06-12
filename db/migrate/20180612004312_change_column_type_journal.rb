class ChangeColumnTypeJournal < ActiveRecord::Migration
  def change
  	remove_column :journals, :exchange_rate
  	add_column :journals, :exchange_rate, :integer
  end
end
