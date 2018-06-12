class ChangeColumnOnJounral < ActiveRecord::Migration
	rename_column :journals, :class,  :class_name
  def change
  end
end
