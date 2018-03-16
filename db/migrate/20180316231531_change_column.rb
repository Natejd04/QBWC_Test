class ChangeColumn < ActiveRecord::Migration
  def change
  	remove_column :orders, :customer_id, :integer
  end
end
