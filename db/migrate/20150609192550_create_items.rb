class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.string :description
      t.string :code
      t.integer :packsize
      t.integer :qty
      t.string :unit

      t.timestamps null: false
    end
  end
end
