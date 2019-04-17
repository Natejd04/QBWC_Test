class AddColumnsToSalesReceipts3 < ActiveRecord::Migration
  def change
    add_column :sales_receipts, :order_status, :string
    add_column :sales_receipts, :site_id, :integer
    add_column :sales_receipts, :user_lock, :integer
    add_column :sales_receipts, :shipped, :boolean, :default => nil
    add_column :sales_receipts, :qb_process, :boolean, :default => nil
    add_column :sales_receipts, :qb_sent_time, :datetime, :default => nil
    add_column :sales_receipts, :sent_to_qb, :boolean, :default => nil
  end
end
