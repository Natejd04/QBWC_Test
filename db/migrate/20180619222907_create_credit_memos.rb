class CreateCreditMemos < ActiveRecord::Migration
  def change
    create_table :credit_memos do |t|
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "c_name"
    t.decimal  "c_total"
    t.string   "c_po"
    t.string   "c_edit"
    t.string   "c_qbid"
    t.date     "c_date"
    t.string   "c_ack"
    t.string   "c_conf"
    t.string   "c_pro"
    t.string   "c_scac"
    t.string   "c_bol"
    t.date     "c_ship"
    t.date     "c_deliver"
    t.date     "c_duedate"
    t.string   "c_terms"
    t.string   "c_invoicenumber"
    t.string   "c_via"
    t.string   "c_memo"
    t.string   "c_ship1"
    t.string   "c_ship2"
    t.string   "c_ship3"
    t.string   "c_ship4"
    t.string   "c_ship5"
    t.string   "c_shipcity"
    t.string   "c_shipstate"
    t.string   "c_shippostal"
    t.string   "c_shipcountry"
    t.string   "c_template"
    t.string   "txn_id"
    t.string   "c_rep"
    t.decimal  "c_balance_due"
    t.decimal  "c_subtotal"
    t.date     "c_qbupdate"
    t.date     "c_qbcreate"
    t.integer  "customer_id"
    t.string   "currency_ref"
    t.decimal  "exchange_rate"
    t.datetime "deleted"
    t.timestamps null: false
    end
  end
end
