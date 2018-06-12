class CreateAccountLineItems < ActiveRecord::Migration
  def change
    create_table :account_line_items do |t|
      t.string :description
      t.string :type
      t.float :amount
      t.string :txn_id
      t.string :class
      t.integer :journal_id
      t.integer :account_id
      t.integer :customer_id
      t.integer :vendor_id

      t.timestamps null: false
    end
  end
end
