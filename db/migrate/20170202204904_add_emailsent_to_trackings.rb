class AddEmailsentToTrackings < ActiveRecord::Migration
  def change
  	add_column :trackings, :emailsent, :date
  end
end
