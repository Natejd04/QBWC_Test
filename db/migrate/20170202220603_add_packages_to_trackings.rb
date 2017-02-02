class AddPackagesToTrackings < ActiveRecord::Migration
  def change
    add_column :trackings, :packages, :string
  end
end
