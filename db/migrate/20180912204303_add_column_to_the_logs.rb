class AddColumnToTheLogs < ActiveRecord::Migration
  def change
    add_column :logs, :status, :string
    add_column :logs, :log_msg, :text
  end
end
