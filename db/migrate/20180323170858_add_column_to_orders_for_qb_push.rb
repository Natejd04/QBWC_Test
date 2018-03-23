class AddColumnToOrdersForQbPush < ActiveRecord::Migration
  def change
    add_column :orders, :qb_process, :boolean
  end
end
