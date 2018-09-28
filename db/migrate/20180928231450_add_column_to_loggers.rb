class AddColumnToLoggers < ActiveRecord::Migration
  def change
  	add_column :logs, :initial_load, :boolean, :default => false
  end
end
