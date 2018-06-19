class ChangeCustomerColumnToListId < ActiveRecord::Migration
  def change
  	rename_column :customers, :listid, :list_id
  end
end
