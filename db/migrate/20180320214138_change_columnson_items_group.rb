class ChangeColumnsonItemsGroup < ActiveRecord::Migration
  def change
  	remove_column :items, :packsize
  	remove_column :items, :qty
  	add_column :items, :type, :string 
  end
end
