class AddListIdColumntoCustomer < ActiveRecord::Migration
  def change
      add_column :customers, :listid, :integer
  end
end
