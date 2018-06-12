class CreateJournals < ActiveRecord::Migration
  def change
    create_table :journals do |t|

      t.timestamps null: false
    end
  end
end
