class FixCutomersColumnName < ActiveRecord::Migration
  def change
  	rename_column :customers, :class_id,  :customer_type_id
  	rename_column :customers, :class_name, :customer_type
  	rename_column :customers, :listid_last, :rep
  end
end
