class AddColumn4ToLineItems < ActiveRecord::Migration
  def change
    add_column :line_items, :site_id, :string
    add_column :line_items, :site_name, :string
  end
end
