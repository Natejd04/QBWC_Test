class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
	  t.string "worker_name"
      t.timestamps null: false
    end
  end
end
