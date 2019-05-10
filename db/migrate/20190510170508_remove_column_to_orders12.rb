class RemoveColumnToOrders12 < ActiveRecord::Migration
  def change
  	remove_column :orders, :address_resedential
  	add_column :orders, :address_residential, :boolean, :default => nil
  end
end
