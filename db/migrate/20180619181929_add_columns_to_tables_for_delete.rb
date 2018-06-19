class AddColumnsToTablesForDelete < ActiveRecord::Migration
  def change
  	add_column :accounts, :deleted, :datetime
  	add_column :customers, :deleted, :datetime
  	add_column :sites, :deleted, :datetime
	add_column :items, :deleted, :datetime
  	add_column :vendors, :deleted, :datetime
  	add_column :orders, :deleted, :datetime
  	add_column :invoices, :deleted, :datetime
  	add_column :sales_receipts, :deleted, :datetime
  	add_column :journals, :deleted, :datetime
  	add_column :bills, :deleted, :datetime
  	add_column :comments, :deleted, :datetime
  end
end
