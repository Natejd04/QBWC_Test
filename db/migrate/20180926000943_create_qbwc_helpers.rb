class CreateQbwcHelpers < ActiveRecord::Migration
  def change
    create_table :qbwc_helpers do |t|
      t.boolean :initial_load, :default => false
      t.date :start
      t.date :end

      t.timestamps null: false
    end
  end
end
