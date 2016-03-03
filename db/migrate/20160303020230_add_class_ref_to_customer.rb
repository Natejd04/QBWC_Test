class AddClassRefToCustomer < ActiveRecord::Migration
  def change
  	add_column :customers, :class_id, :string
    add_column :customers, :class_name, :string
  end
end
