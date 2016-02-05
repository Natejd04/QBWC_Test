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

ActiveRecord::Schema.define(version: 20160205015755) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bills", force: :cascade do |t|
    t.string   "txn_id"
    t.string   "ref_number"
    t.string   "name"
    t.date     "txn_date"
    t.date     "due_date"
    t.float    "amount_due"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.string   "listid"
    t.string   "edit_sq"
    t.string   "ship_address"
    t.string   "ship_address2"
    t.string   "ship_address3"
    t.string   "ship_address4"
    t.string   "ship_city"
    t.string   "ship_state"
    t.string   "ship_zip"
    t.string   "ship_address5"
  end

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "code"
    t.integer  "packsize"
    t.float    "qty"
    t.string   "unit"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "edit_sq"
    t.string   "list_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.string   "order_id"
    t.string   "item_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "qty"
    t.float    "amount"
    t.string   "product_name"
    t.string   "description"
    t.string   "site_id"
    t.string   "site_name"
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
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "docs_file_name"
    t.string   "docs_content_type"
    t.integer  "docs_file_size"
    t.datetime "docs_updated_at"
    t.boolean  "remove_docs",       default: false
    t.string   "customer_id"
    t.integer  "lineitem_id"
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
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "salt"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "role"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

end
