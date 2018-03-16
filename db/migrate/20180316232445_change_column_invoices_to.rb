class ChangeColumnInvoicesTo < ActiveRecord::Migration
  def change
  	remove_column :invoices, :customer_id, :integer
  end
end
