class ChangeInvoiceDatetoDateTime < ActiveRecord::Migration
  def up
    change_column :invoices, :c_date, :datetime
  end

  def down
    change_column :invoices, :c_date, :date
  end
end
