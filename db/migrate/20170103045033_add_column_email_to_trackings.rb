class AddColumnEmailToTrackings < ActiveRecord::Migration
  def change
    add_column :trackings, :txn_date, :date
    add_column :trackings, :emailed, :boolean
  end
end
