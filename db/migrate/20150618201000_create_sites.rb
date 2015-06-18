class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :list_id
      t.string :edit_sq
      t.string :name
      t.string :description
      t.string :contact
      t.string :phone
      t.string :email
      t.string :address
      t.string :address2
      t.string :address3
      t.string :address4
      t.string :address5
      t.string :city
      t.string :state
      t.string :postal

      t.timestamps null: false
    end
  end
end
