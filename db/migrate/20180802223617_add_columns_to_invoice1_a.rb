class AddColumnsToInvoice1A < ActiveRecord::Migration
  def change
  	 add_column :invoices, :memo, :string
  	 add_column :invoices, :fob, :string
  	 add_column :invoices, :emailed, :boolean
  	 add_column :invoices, :email, :string
  	 add_column :invoices, :tracking, :string
  	 add_column :invoices, :ship_method, :string
  	 add_column :invoices, :emailable, :boolean
  end
end
