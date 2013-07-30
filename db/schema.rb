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

ActiveRecord::Schema.define(version: 20130327170939) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "accounts", force: true do |t|
    t.integer  "organization_id",             null: false
    t.string   "first_name",      limit: 40,  null: false
    t.string   "last_name",       limit: 40,  null: false
    t.string   "email",           limit: 100, null: false
    t.string   "hashed_password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
  add_index "accounts", ["organization_id"], name: "fk_organization_id", using: :btree

  create_table "annotations", force: true do |t|
    t.integer  "organization_id",                       null: false
    t.integer  "account_id",                            null: false
    t.integer  "document_id",                           null: false
    t.integer  "page_number",                           null: false
    t.integer  "access",                                null: false
    t.string   "title",                                 null: false
    t.text     "content"
    t.string   "location",                   limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.tsvector "annotations_content_vector"
  end

  add_index "annotations", ["annotations_content_vector"], name: "annotations_content_fti", using: :gin
  add_index "annotations", ["document_id"], name: "index_annotations_on_document_id", using: :btree

  create_table "app_constants", force: true do |t|
    t.string "key"
    t.string "value"
  end

  create_table "bookmarks", force: true do |t|
    t.integer "account_id",              null: false
    t.integer "document_id",             null: false
    t.integer "page_number",             null: false
    t.string  "title",       limit: 100, null: false
  end

  add_index "bookmarks", ["account_id"], name: "index_bookmarks_on_account_id", using: :btree

  create_table "collaborations", force: true do |t|
    t.integer "project_id", null: false
    t.integer "account_id", null: false
    t.integer "creator_id"
  end

  create_table "docdata", force: true do |t|
    t.integer "document_id", null: false
    t.hstore  "data"
  end

  add_index "docdata", ["data"], name: "index_docdata_on_data", using: :gin

  create_table "document_reviewers", force: true do |t|
    t.integer  "account_id",  null: false
    t.integer  "document_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", force: true do |t|
    t.integer  "organization_id",                                null: false
    t.integer  "account_id",                                     null: false
    t.integer  "access",                                         null: false
    t.integer  "page_count",                         default: 0, null: false
    t.string   "title",                                          null: false
    t.string   "slug",                                           null: false
    t.string   "source"
    t.string   "language",                limit: 3
    t.string   "summary"
    t.string   "calais_id",               limit: 40
    t.date     "publication_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.tsvector "documents_title_vector"
    t.tsvector "documents_source_vector"
  end

  add_index "documents", ["access"], name: "index_documents_on_access", using: :btree
  add_index "documents", ["account_id"], name: "index_documents_on_account_id", using: :btree
  add_index "documents", ["documents_source_vector"], name: "documents_source_fti", using: :gin
  add_index "documents", ["documents_title_vector"], name: "documents_title_fti", using: :gin
  add_index "documents", ["organization_id"], name: "foo2", using: :btree

  create_table "entities", id: false, force: true do |t|
    t.integer "id",                                       null: false
    t.integer "organization_id",                          null: false
    t.integer "account_id",                               null: false
    t.integer "document_id",                              null: false
    t.integer "access",                                   null: false
    t.string  "kind",            limit: 40,               null: false
    t.string  "value",                                    null: false
    t.float   "relevance",                  default: 0.0, null: false
    t.string  "calais_id",       limit: 40
    t.text    "occurrences"
  end

  create_table "entity_dates", id: false, force: true do |t|
    t.integer "id",              null: false
    t.integer "organization_id", null: false
    t.integer "account_id",      null: false
    t.integer "document_id",     null: false
    t.integer "access",          null: false
    t.date    "date",            null: false
    t.text    "occurrences"
  end

  add_index "entity_dates", ["document_id", "date"], name: "index_metadata_dates_on_document_id_and_date", unique: true, using: :btree

  create_table "featured_reports", force: true do |t|
    t.string   "url",                       null: false
    t.string   "title",                     null: false
    t.string   "organization",              null: false
    t.date     "article_date",              null: false
    t.text     "writeup",                   null: false
    t.integer  "present_order", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "full_text", force: true do |t|
    t.integer  "organization_id",       null: false
    t.integer  "account_id",            null: false
    t.integer  "document_id",           null: false
    t.integer  "access",                null: false
    t.text     "text",                  null: false
    t.tsvector "full_text_text_vector"
  end

  add_index "full_text", ["document_id"], name: "index_full_text_on_document_id", unique: true, using: :btree
  add_index "full_text", ["full_text_text_vector"], name: "full_text_text_fti", using: :gin

  create_table "labels", force: true do |t|
    t.integer "account_id",               null: false
    t.string  "title",        limit: 100, null: false
    t.text    "document_ids"
  end

  add_index "labels", ["account_id"], name: "index_labels_on_account_id", using: :btree

  create_table "memberships", force: true do |t|
    t.integer "organization_id",                 null: false
    t.integer "account_id",                      null: false
    t.integer "role",                            null: false
    t.boolean "default",         default: false
    t.boolean "concealed",       default: false
  end

  add_index "memberships", ["account_id"], name: "index_memberships_on_account_id", using: :btree
  add_index "memberships", ["organization_id"], name: "index_memberships_on_organization_id", using: :btree

  create_table "metadata", force: true do |t|
    t.integer  "organization_id",                                null: false
    t.integer  "account_id",                                     null: false
    t.integer  "document_id",                                    null: false
    t.integer  "access",                                         null: false
    t.string   "kind",                  limit: 40,               null: false
    t.string   "value",                                          null: false
    t.float    "relevance",                        default: 0.0, null: false
    t.string   "calais_id",             limit: 40
    t.text     "occurrences"
    t.tsvector "metadata_value_vector"
  end

  add_index "metadata", ["document_id"], name: "index_metadata_on_document_id", using: :btree
  add_index "metadata", ["kind"], name: "index_metadata_on_kind", using: :btree
  add_index "metadata", ["metadata_value_vector"], name: "metadata_value_fti", using: :gin

  create_table "metadata_dates", force: true do |t|
    t.integer "organization_id", null: false
    t.integer "account_id",      null: false
    t.integer "document_id",     null: false
    t.integer "access",          null: false
    t.date    "date",            null: false
    t.text    "occurrences"
  end

  add_index "metadata_dates", ["document_id"], name: "index_metadata_dates_on_document_id", using: :btree

  create_table "organizations", force: true do |t|
    t.string   "name",       limit: 100, null: false
    t.string   "slug",       limit: 100, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["name"], name: "index_organizations_on_name", unique: true, using: :btree
  add_index "organizations", ["slug"], name: "index_organizations_on_slug", unique: true, using: :btree

  create_table "pages", force: true do |t|
    t.integer  "organization_id",   null: false
    t.integer  "account_id",        null: false
    t.integer  "document_id",       null: false
    t.integer  "access",            null: false
    t.integer  "page_number",       null: false
    t.text     "text",              null: false
    t.tsvector "pages_text_vector"
    t.integer  "start_offset"
    t.integer  "end_offset"
  end

  add_index "pages", ["document_id", "page_number"], name: "index_pages_on_document_id_and_page_number", unique: true, using: :btree
  add_index "pages", ["document_id"], name: "index_pages_on_document_id", using: :btree
  add_index "pages", ["page_number"], name: "index_pages_on_page_number", using: :btree
  add_index "pages", ["pages_text_vector"], name: "pages_text_fti", using: :gin
  add_index "pages", ["start_offset", "end_offset"], name: "index_pages_on_start_offset_and_end_offset", using: :btree

  create_table "pending_memberships", force: true do |t|
    t.string   "first_name",                        null: false
    t.string   "last_name",                         null: false
    t.string   "email",                             null: false
    t.string   "organization_name",                 null: false
    t.string   "usage",                             null: false
    t.string   "editor"
    t.string   "website"
    t.boolean  "validated",         default: false, null: false
    t.text     "notes"
    t.integer  "organization_id"
    t.hstore   "fields"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "processing_jobs", force: true do |t|
    t.integer "account_id",     null: false
    t.integer "cloud_crowd_id", null: false
    t.string  "title",          null: false
  end

  add_index "processing_jobs", ["account_id"], name: "index_processing_jobs_on_account_id", using: :btree

  create_table "project_memberships", force: true do |t|
    t.integer "project_id",  null: false
    t.integer "document_id", null: false
  end

  add_index "project_memberships", ["document_id"], name: "index_project_memberships_on_document_id", using: :btree
  add_index "project_memberships", ["project_id"], name: "index_project_memberships_on_project_id", using: :btree

  create_table "projects", id: false, force: true do |t|
    t.integer "id",                          null: false
    t.integer "account_id"
    t.string  "title"
    t.text    "description"
    t.boolean "hidden",      default: false, null: false
  end

  create_table "remote_urls", force: true do |t|
    t.integer "document_id",             null: false
    t.string  "url",                     null: false
    t.integer "hits",        default: 0, null: false
  end

  create_table "saved_searches", force: true do |t|
    t.integer "account_id", null: false
    t.string  "query",      null: false
  end

  add_index "saved_searches", ["account_id"], name: "index_saved_searches_on_account_id", using: :btree

  create_table "sections", force: true do |t|
    t.integer "organization_id", null: false
    t.integer "account_id",      null: false
    t.integer "document_id",     null: false
    t.integer "access",          null: false
    t.string  "title",           null: false
    t.integer "start_page",      null: false
    t.integer "end_page",        null: false
  end

  add_index "sections", ["document_id"], name: "index_sections_on_document_id", using: :btree

  create_table "security_keys", force: true do |t|
    t.string  "securable_type", limit: 40, null: false
    t.integer "securable_id",              null: false
    t.string  "key",            limit: 40
  end

end
