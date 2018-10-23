class CreateApiHooks < ActiveRecord::Migration
  def change
    create_table :api_hooks do |t|
      t.string :token
      t.string :auth_key
      t.string :url

      t.timestamps null: false
    end
  end
end
