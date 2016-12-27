class AddShipMethodToTracking < ActiveRecord::Migration
  def change
    add_column :trackings, :ship_method, :string
  end
end
