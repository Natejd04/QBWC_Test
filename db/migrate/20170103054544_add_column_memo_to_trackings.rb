class AddColumnMemoToTrackings < ActiveRecord::Migration
  def change
    add_column :trackings, :memo, :string
  end
end
