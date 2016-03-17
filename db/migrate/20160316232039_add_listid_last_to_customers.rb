class AddListidLastToCustomers < ActiveRecord::Migration
  def change
  	add_column :customers, :listid_last, :string
  end
end
