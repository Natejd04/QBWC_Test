class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :name
      t.string :company
      t.string :address1
      t.string :address2
      t.string :address3
      t.string :address4
      t.string :address5
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :contact_name
      t.string :contact_value
      t.string :balance
      t.string :currency_ref
      t.datetime :qb_created
      t.datetime :qb_modified
      t.string :edit_sq
      t.string :list_id

      t.timestamps null: false
    end
  end
end
