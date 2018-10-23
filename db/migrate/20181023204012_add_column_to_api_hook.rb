class AddColumnToApiHook < ActiveRecord::Migration
  def change
    add_column :api_hooks, :salt, :string
  end
end
