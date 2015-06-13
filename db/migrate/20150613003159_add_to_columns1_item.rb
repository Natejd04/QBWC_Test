class AddToColumns1Item < ActiveRecord::Migration
  def change
      add_column :items, :edit_sq, :string
      add_column :items, :list_id, :string
      change_column :items, :qty, :float
  end
end
