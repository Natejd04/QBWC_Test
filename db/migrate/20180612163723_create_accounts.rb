class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :description
      t.integer :number
      t.string :edit_sq
      t.string :list_id
      t.string :currency
      t.decimal :balance
      t.string :type
      t.boolean :active
      t.datetime :qb_created
      t.datetime :qb_modified

      t.timestamps null: false
    end
  end
end
