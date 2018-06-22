class AddColumnToSites01 < ActiveRecord::Migration
  def change
    add_column :sites, :active, :boolean
  end
end
