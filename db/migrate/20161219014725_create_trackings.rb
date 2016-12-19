class CreateTrackings < ActiveRecord::Migration
  def change
    create_table :trackings do |t|
      t.string :txn_id
      t.date :time_created
      t.text :name
      t.string :template_ref
      t.string :email
      t.string :tracking

      t.timestamps null: false
    end
  end
end
