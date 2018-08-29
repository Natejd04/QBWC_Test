class AddColumnForDataExttoItem < ActiveRecord::Migration
  def change
  	add_column :items, :upc, :string
  end
end
