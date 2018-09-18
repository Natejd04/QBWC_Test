class AddColumnToLoggingDates < ActiveRecord::Migration
  def change
    add_column :logs, :start_date, :date
    add_column :logs, :end_date, :date
  end
end
