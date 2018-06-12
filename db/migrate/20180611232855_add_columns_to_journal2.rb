class AddColumnsToJournal2 < ActiveRecord::Migration
  def change
    add_column :journals, :qbcreate, :date
    add_column :journals, :qbupdate, :date
  end
end
