class CreateSalesReceipts < ActiveRecord::Migration
  def change
    create_table :sales_receipts do |t|
      t.string :txn_id
      t.string :invoicenumber
      t.string :qb_edit
      t.datetime :txn_date
      t.string :currency_ref
      t.decimal :exchange_rate
      t.float :subtotal
      t.string :template
      t.datetime :qb_create
      t.datetime :qb_update
      t.string :po_number
      t.string :class_name
      t.string :ship_date
      t.string :due_date
      t.string :ship_via
      t.integer :customer_id
      t.string :name
      t.string :ship1
      t.string :ship2
      t.string :ship3
      t.string :ship4
      t.string :ship5
      t.string :shipcity
      t.string :shipstate
      t.string :shippostal
      t.string :shipcountry
      t.string :sales_rep

      t.timestamps null: false
    end
  end
end
