# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190510170832) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_line_items", force: :cascade do |t|
    t.string   "description"
    t.float    "amount"
    t.string   "txn_id"
    t.integer  "journal_id"
    t.integer  "account_id"
    t.integer  "customer_id"
    t.integer  "vendor_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "account_type"
    t.string   "class_name"
    t.string   "memo"
  end

  create_table "accounts", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "number"
    t.string   "edit_sq"
    t.string   "list_id"
    t.string   "currency"
    t.decimal  "balance"
    t.boolean  "active"
    t.datetime "qb_created"
    t.datetime "qb_modified"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "account_type"
    t.integer  "sublevel"
    t.datetime "deleted"
  end

  create_table "api_hooks", force: :cascade do |t|
    t.string   "token"
    t.string   "auth_key"
    t.string   "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "salt"
  end

  create_table "bills", force: :cascade do |t|
    t.string   "txn_id"
    t.string   "ref_number"
    t.string   "name"
    t.date     "txn_date"
    t.date     "due_date"
    t.float    "amount_due"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted"
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "order_id"
    t.text     "body"
    t.integer  "user_id"
    t.integer  "customer_id"
    t.boolean  "notified"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "sales_receipt_id"
    t.datetime "deleted"
  end

  create_table "credit_memos", force: :cascade do |t|
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
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
    t.string   "c_class"
  end

  create_table "customers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.string   "list_id"
    t.string   "edit_sq"
    t.string   "ship_address"
    t.string   "ship_address2"
    t.string   "ship_address3"
    t.string   "ship_address4"
    t.string   "ship_city"
    t.string   "ship_state"
    t.string   "ship_zip"
    t.string   "ship_address5"
    t.string   "customer_type_id"
    t.string   "customer_type"
    t.string   "rep"
    t.string   "email"
    t.date     "qbcreate"
    t.date     "qbupdate"
    t.datetime "deleted"
  end

  create_table "invoices", force: :cascade do |t|
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "c_name"
    t.decimal  "c_total"
    t.string   "c_po"
    t.string   "c_edit"
    t.string   "c_qbid"
    t.datetime "c_date"
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
    t.string   "docs_file_name"
    t.string   "docs_content_type"
    t.integer  "docs_file_size"
    t.datetime "docs_updated_at"
    t.boolean  "remove_docs",       default: false
    t.string   "c_class"
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
    t.string   "sales_order_txn"
    t.string   "sales_order_ref"
    t.string   "memo"
    t.string   "fob"
    t.string   "email"
    t.string   "tracking"
    t.string   "ship_method"
    t.boolean  "emailable"
    t.boolean  "to_email"
    t.datetime "emailed"
  end

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "code"
    t.string   "unit"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "edit_sq"
    t.string   "list_id"
    t.string   "item_type"
    t.integer  "account_id"
    t.datetime "deleted"
    t.string   "upc"
  end

  create_table "journals", force: :cascade do |t|
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "txn_id"
    t.string   "txn_number"
    t.string   "qb_edit"
    t.date     "txn_date"
    t.string   "ref_number"
    t.string   "currency_ref"
    t.string   "account_number"
    t.decimal  "amount"
    t.string   "memo"
    t.string   "class_name"
    t.date     "qbcreate"
    t.date     "qbupdate"
    t.integer  "exchange_rate"
    t.datetime "deleted"
  end

  create_table "line_items", force: :cascade do |t|
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "qty"
    t.float    "amount"
    t.string   "description"
    t.string   "txn_id"
    t.integer  "order_id"
    t.integer  "site_id"
    t.integer  "item_id"
    t.integer  "sales_receipt_id"
    t.float    "homecurrency_amount"
    t.integer  "credit_memo_id"
    t.integer  "invoice_id"
  end

  create_table "logs", force: :cascade do |t|
    t.string   "worker_name"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "status"
    t.text     "log_msg"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "initial_load", default: false
    t.string   "ip"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "recipient_id"
    t.integer  "actor_id"
    t.datetime "read_at"
    t.string   "action"
    t.integer  "notifiable_id"
    t.string   "notifiable_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "orders", force: :cascade do |t|
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
    t.string   "c_via"
    t.string   "c_memo"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "docs_file_name"
    t.string   "docs_content_type"
    t.integer  "docs_file_size"
    t.datetime "docs_updated_at"
    t.boolean  "remove_docs",          default: false
    t.string   "c_class"
    t.string   "c_ship1"
    t.string   "c_ship2"
    t.string   "c_shipcity"
    t.string   "c_shipstate"
    t.string   "c_shippostal"
    t.string   "c_shipcountry"
    t.string   "c_invoiced"
    t.string   "c_closed"
    t.string   "c_template"
    t.string   "c_ship3"
    t.string   "c_ship4"
    t.string   "c_ship5"
    t.string   "txn_id"
    t.string   "c_rep"
    t.string   "invoice_number"
    t.date     "qbcreate"
    t.date     "qbupdate"
    t.integer  "customer_id"
    t.string   "currency_ref"
    t.integer  "exchange_rate"
    t.boolean  "qb_process"
    t.datetime "deleted"
    t.boolean  "send_to_qb"
    t.datetime "qb_sent_time"
    t.datetime "confirmed_time"
    t.integer  "user_confirmed"
    t.string   "address_type_code"
    t.boolean  "address_residential"
    t.string   "amazon_df_cust_order"
  end

  create_table "qb_helpers", force: :cascade do |t|
    t.boolean  "initial_load", default: false
    t.date     "start"
    t.date     "end"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  create_table "qbwc_jobs", force: :cascade do |t|
    t.string   "name"
    t.string   "company",                          limit: 1000
    t.string   "worker_class",                     limit: 100
    t.boolean  "enabled",                                       default: false, null: false
    t.integer  "request_index",                                 default: 0,     null: false
    t.text     "requests"
    t.boolean  "requests_provided_when_job_added",              default: false, null: false
    t.text     "data"
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
  end

  create_table "qbwc_sessions", force: :cascade do |t|
    t.string   "ticket"
    t.string   "user"
    t.string   "company",      limit: 1000
    t.integer  "progress",                  default: 0,  null: false
    t.string   "current_job"
    t.string   "iterator_id"
    t.string   "error",        limit: 1000
    t.string   "pending_jobs", limit: 1000, default: "", null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "sales_receipts", force: :cascade do |t|
    t.string   "txn_id"
    t.string   "invoicenumber"
    t.string   "qb_edit"
    t.datetime "txn_date"
    t.string   "currency_ref"
    t.decimal  "exchange_rate"
    t.float    "subtotal"
    t.string   "template"
    t.datetime "qb_create"
    t.datetime "qb_update"
    t.string   "po_number"
    t.string   "class_name"
    t.string   "ship_date"
    t.string   "due_date"
    t.string   "ship_via"
    t.integer  "customer_id"
    t.string   "name"
    t.string   "ship1"
    t.string   "ship2"
    t.string   "ship3"
    t.string   "ship4"
    t.string   "ship5"
    t.string   "shipcity"
    t.string   "shipstate"
    t.string   "shippostal"
    t.string   "shipcountry"
    t.string   "sales_rep"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.datetime "deleted"
    t.string   "order_status"
    t.integer  "site_id"
    t.integer  "user_lock"
    t.boolean  "shipped"
    t.boolean  "qb_process"
    t.datetime "qb_sent_time"
    t.boolean  "sent_to_qb"
  end

  create_table "site_inventories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float    "qty"
    t.float    "qty_so"
    t.integer  "site_id"
    t.integer  "item_id"
  end

  create_table "sites", force: :cascade do |t|
    t.string   "list_id"
    t.string   "edit_sq"
    t.string   "name"
    t.string   "description"
    t.string   "contact"
    t.string   "phone"
    t.string   "email"
    t.string   "address"
    t.string   "address2"
    t.string   "address3"
    t.string   "address4"
    t.string   "address5"
    t.string   "city"
    t.string   "state"
    t.string   "postal"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.datetime "deleted"
    t.boolean  "active"
  end

  create_table "trackings", force: :cascade do |t|
    t.string   "txn_id"
    t.date     "time_created"
    t.text     "name"
    t.string   "template_ref"
    t.string   "email"
    t.string   "tracking"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "ship_method"
    t.date     "txn_date"
    t.boolean  "emailed"
    t.string   "memo"
    t.date     "emailsent"
    t.string   "ship1"
    t.string   "ship2"
    t.string   "ship3"
    t.string   "ship4"
    t.string   "ship5"
    t.string   "shipcity"
    t.string   "shipstate"
    t.string   "shippostal"
    t.string   "shipcountry"
    t.string   "packages"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "salt"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "role"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "phone"
    t.boolean  "locked"
    t.string   "email_frequency"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0, null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "homepage"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vendors", force: :cascade do |t|
    t.string   "name"
    t.string   "company"
    t.string   "address1"
    t.string   "address2"
    t.string   "address3"
    t.string   "address4"
    t.string   "address5"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "balance"
    t.string   "currency_ref"
    t.datetime "qb_created"
    t.datetime "qb_modified"
    t.string   "edit_sq"
    t.string   "list_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "f_name"
    t.string   "l_name"
    t.string   "email"
    t.datetime "deleted"
  end

end
