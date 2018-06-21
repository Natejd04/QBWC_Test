class AddColumnForOrder01 < ActiveRecord::Migration
  def change
  	add_column :orders, :send_to_qb, :boolean
  	add_column :orders, :qb_sent_time, :datetime
  	add_column :orders, :confirmed_time, :datetime
  	add_column :orders, :user_confirmed, :integer
  end
end
