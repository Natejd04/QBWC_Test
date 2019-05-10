class AddColumnsToOrders10 < ActiveRecord::Migration
  def change
  	add_column :orders, :address_type_code, :string
  	add_column :orders, :address_resedential, :boolean, :default => nil
  end
end
