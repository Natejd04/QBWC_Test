class ChangeListidToString < ActiveRecord::Migration
  def change
      change_column :customers, :listid, :string
      change_column :customers, :edit_sq, :string
  end
end
