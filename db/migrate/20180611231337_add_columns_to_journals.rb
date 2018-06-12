class AddColumnsToJournals < ActiveRecord::Migration
  def change
  	add_column :journals, :txn_id, :string
  	add_column :journals, :txn_number, :string
  	add_column :journals, :qb_edit, :string
  	add_column :journals, :txn_date, :date
	add_column :journals, :ref_number, :string
	add_column :journals, :currency_ref, :string
	add_column :journals, :exchange_rate, :decimal
	add_column :journals, :account_number, :string
	add_column :journals, :amount, :decimal
	add_column :journals, :memo, :string
	add_column :journals, :class, :string  	
  end
end