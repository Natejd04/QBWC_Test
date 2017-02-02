class AddShippingToTracking < ActiveRecord::Migration
  def change
    add_column :trackings, :ship1, :string
    add_column :trackings, :ship2, :string
    add_column :trackings, :ship3, :string
    add_column :trackings, :ship4, :string
    add_column :trackings, :ship5, :string
    add_column :trackings, :shipcity, :string
    add_column :trackings, :shipstate, :string
    add_column :trackings, :shippostal, :string
    add_column :trackings, :shipcountry, :string
  end
end
