class AddColumnTo2Orders < ActiveRecord::Migration
  def change
  	add_column :orders, :c_rep, :string
  end
end
