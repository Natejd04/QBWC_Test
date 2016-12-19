class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.string :txn_id
      t.string :ref_number
      t.string :name
      t.date :txn_date
      t.date :due_date
      t.integer :amount_due

      t.timestamps null: false
    end
  end
end
