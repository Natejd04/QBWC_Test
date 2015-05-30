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

ActiveRecord::Schema.define(version: 20150515001215) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "address"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.string   "listid"
    t.string   "edit_sq"
  end

  create_table "orders", force: :cascade do |t|
    t.string   "c_name"
    t.decimal  "c_total"
    t.integer  "m_ab"
    t.integer  "m_cc"
    t.integer  "m_ccc"
    t.integer  "m_co"
    t.integer  "m_cpb"
    t.integer  "m_dch"
    t.integer  "m_dcm"
    t.integer  "m_dnb"
    t.integer  "m_moc"
    t.integer  "m_lcc"
    t.integer  "m_occ"
    t.integer  "m_pbcc"
    t.integer  "c_ab"
    t.integer  "c_cc"
    t.integer  "c_ccc"
    t.integer  "c_co"
    t.integer  "c_cpb"
    t.integer  "c_dch"
    t.integer  "c_dcm"
    t.integer  "c_dnb"
    t.integer  "c_moc"
    t.integer  "c_lcc"
    t.integer  "c_occ"
    t.integer  "c_pbcc"
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
