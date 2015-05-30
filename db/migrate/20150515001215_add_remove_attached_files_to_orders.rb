class AddRemoveAttachedFilesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :remove_docs, :boolean, :default => false
  end
end
