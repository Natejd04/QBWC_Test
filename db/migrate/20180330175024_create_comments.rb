class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer "order_id"
      t.text "body"
      t.integer "user_id"
      t.integer "customer_id"
      t.boolean "notified"

      t.timestamps null: false
    end
  end
end
