class ChangeColumnNotificationToName < ActiveRecord::Migration
  def change
  	rename_column :notifications, :notifiable_string, :notifiable_type
  end
end
