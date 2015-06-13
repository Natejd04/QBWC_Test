class AddColumn2ToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :product_name, :string
  end
end
