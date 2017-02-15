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

ActiveRecord::Schema.define(version: 20170124201757) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "accounts", force: :cascade do |t|
    t.string   "first_name",        limit: 40
    t.string   "last_name",         limit: 40
    t.string   "email",             limit: 100
    t.string   "hashed_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "language",          limit: 3,   default: "eng"
    t.string   "document_language", limit: 3,   default: "eng"
    t.string   "provider"
    t.string   "access_token"
    t.integer  "uid"
  end

  add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree

  create_table "annotations", force: :cascade do |t|
    t.integer  "organization_id",                null: false
    t.integer  "account_id",                     null: false
    t.integer  "document_id",                    null: false
    t.integer  "page_number",                    null: false
    t.integer  "access",                         null: false
    t.text     "title",                          null: false
    t.text     "content"
    t.string   "location",            limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "moderation_approval"
  end

  add_index "annotations", ["document_id"], name: "index_annotations_on_document_id", using: :btree

  create_table "app_constants", force: :cascade do |t|
    t.string "key"
    t.string "value"
  end

  create_table "bull_proof_china_shop_account_requests", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "requester_email"
    t.string   "requester_first_name"
    t.string   "requester_last_name"
    t.text     "requester_notes"
    t.string   "organization_name"
    t.string   "organization_url"
    t.string   "approver_email"
    t.string   "approver_first_name"
    t.string   "approver_last_name"
    t.string   "country",                              null: false
    t.text     "verification_notes"
    t.integer  "status",               default: 1
    t.boolean  "agreed_to_terms",      default: false
    t.boolean  "authorized_posting",   default: false
    t.string   "token"
    t.string   "industry"
    t.text     "use_case"
    t.text     "reference_links"
    t.boolean  "marketing_optin",      default: false
    t.boolean  "in_market",            default: false
    t.string   "requester_position"
  end

  create_table "bull_proof_china_shop_accounts", force: :cascade do |t|
    t.string   "stripe_customer_id"
    t.text     "billing_email"
    t.integer  "dc_membership_id"
    t.integer  "dc_membership_role"
    t.integer  "dc_organization_id"
    t.integer  "dc_account_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "bull_proof_china_shop_permits", force: :cascade do |t|
    t.string   "stripe_plan_id"
    t.string   "stripe_customer_id"
    t.string   "stripe_card_id"
    t.integer  "dc_membership_id"
    t.integer  "dc_account_id"
    t.integer  "dc_organization_id"
    t.integer  "dc_membership_role"
    t.integer  "status",                 default: 1
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "stripe_subscription_id"
    t.string   "stripe_customer_email"
    t.integer  "stripe_card_last4"
    t.integer  "account_id"
    t.datetime "start_date"
    t.datetime "end_date_scheduled"
    t.datetime "end_date_actual"
  end

  create_table "collaborations", force: :cascade do |t|
    t.integer "project_id",                    null: false
    t.integer "account_id",                    null: false
    t.integer "creator_id"
    t.integer "membership_id"
    t.boolean "hidden",        default: false
  end

  add_index "collaborations", ["membership_id"], name: "index_collaborations_on_membership_id", using: :btree

  create_table "docdata", force: :cascade do |t|
    t.integer "document_id", null: false
    t.hstore  "data"
  end

  add_index "docdata", ["data"], name: "index_docdata_on_data", using: :gin

  create_table "document_reviewers", force: :cascade do |t|
    t.integer  "account_id",  null: false
    t.integer  "document_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "documents", force: :cascade do |t|
    t.integer  "organization_id",                                  null: false
    t.integer  "account_id",                                       null: false
    t.integer  "access",                                           null: false
    t.integer  "page_count",                       default: 0,     null: false
    t.string   "title",               limit: 1000,                 null: false
    t.string   "slug",                                             null: false
    t.string   "source",              limit: 1000
    t.string   "language",            limit: 3
    t.text     "description"
    t.string   "calais_id",           limit: 40
    t.date     "publication_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "related_article"
    t.text     "detected_remote_url"
    t.text     "remote_url"
    t.datetime "publish_at"
    t.boolean  "text_changed",                     default: false, null: false
    t.integer  "hit_count",                        default: 0,     null: false
    t.integer  "public_note_count",                default: 0,     null: false
    t.integer  "reviewer_count",                   default: 0,     null: false
    t.integer  "file_size",                        default: 0,     null: false
    t.integer  "char_count",                       default: 0,     null: false
    t.string   "original_extension"
    t.text     "file_hash"
  end

  add_index "documents", ["access"], name: "index_documents_on_access", using: :btree
  add_index "documents", ["account_id"], name: "index_documents_on_account_id", using: :btree
  add_index "documents", ["file_hash"], name: "index_documents_on_file_hash", using: :btree
  add_index "documents", ["hit_count"], name: "index_documents_on_hit_count", using: :btree
  add_index "documents", ["public_note_count"], name: "index_documents_on_public_note_count", using: :btree

  create_table "entities", force: :cascade do |t|
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

  add_index "entities", ["document_id"], name: "index_metadata_on_document_id", using: :btree
  add_index "entities", ["kind"], name: "index_metadata_on_kind", using: :btree

  create_table "entity_dates", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "account_id",      null: false
    t.integer "document_id",     null: false
    t.integer "access",          null: false
    t.date    "date",            null: false
    t.text    "occurrences"
  end

  add_index "entity_dates", ["document_id", "date"], name: "index_metadata_dates_on_document_id_and_date", unique: true, using: :btree

  create_table "featured_reports", force: :cascade do |t|
    t.string   "url",                       null: false
    t.string   "title",                     null: false
    t.string   "organization",              null: false
    t.date     "article_date",              null: false
    t.text     "writeup",                   null: false
    t.integer  "present_order", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "organization_id",                 null: false
    t.integer "account_id",                      null: false
    t.integer "role",                            null: false
    t.boolean "default",         default: false
    t.boolean "concealed",       default: false
  end

  add_index "memberships", ["account_id"], name: "index_memberships_on_account_id", using: :btree
  add_index "memberships", ["organization_id"], name: "index_memberships_on_organization_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "name",              limit: 100,                 null: false
    t.string   "slug",              limit: 100,                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "demo",                          default: false, null: false
    t.string   "language",          limit: 3
    t.string   "document_language", limit: 3
  end

  add_index "organizations", ["name"], name: "index_organizations_on_name", unique: true, using: :btree
  add_index "organizations", ["slug"], name: "index_organizations_on_slug", unique: true, using: :btree

  create_table "pages", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "account_id",      null: false
    t.integer "document_id",     null: false
    t.integer "access",          null: false
    t.integer "page_number",     null: false
    t.text    "text",            null: false
    t.integer "start_offset"
    t.integer "end_offset"
    t.float   "aspect_ratio"
  end

  add_index "pages", ["document_id"], name: "index_pages_on_document_id", using: :btree
  add_index "pages", ["page_number"], name: "index_pages_on_page_number", using: :btree
  add_index "pages", ["start_offset", "end_offset"], name: "index_pages_on_start_offset_and_end_offset", using: :btree

  create_table "pending_memberships", force: :cascade do |t|
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

  create_table "processing_jobs", force: :cascade do |t|
    t.integer "account_id",                     null: false
    t.integer "cloud_crowd_id",                 null: false
    t.string  "title",                          null: false
    t.integer "document_id"
    t.string  "action"
    t.string  "options"
    t.boolean "complete",       default: false
  end

  add_index "processing_jobs", ["account_id"], name: "index_processing_jobs_on_account_id", using: :btree
  add_index "processing_jobs", ["action"], name: "index_processing_jobs_on_action", using: :btree
  add_index "processing_jobs", ["cloud_crowd_id"], name: "index_processing_jobs_on_cloud_crowd_id", using: :btree
  add_index "processing_jobs", ["document_id"], name: "index_processing_jobs_on_document_id", using: :btree

  create_table "project_memberships", force: :cascade do |t|
    t.integer "project_id",  null: false
    t.integer "document_id", null: false
  end

  add_index "project_memberships", ["document_id"], name: "index_project_memberships_on_document_id", using: :btree
  add_index "project_memberships", ["project_id"], name: "index_project_memberships_on_project_id", using: :btree

  create_table "project_organizations", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_organizations", ["organization_id"], name: "index_project_organizations_on_organization_id", using: :btree
  add_index "project_organizations", ["project_id"], name: "index_project_organizations_on_project_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.integer "account_id"
    t.string  "title"
    t.text    "description"
    t.boolean "hidden",      default: false, null: false
  end

  add_index "projects", ["account_id"], name: "index_labels_on_account_id", using: :btree

  create_table "remote_urls", force: :cascade do |t|
    t.integer "document_id",             null: false
    t.string  "url",                     null: false
    t.integer "hits",        default: 0, null: false
  end

  create_table "sections", force: :cascade do |t|
    t.integer "organization_id", null: false
    t.integer "account_id",      null: false
    t.integer "document_id",     null: false
    t.text    "title",           null: false
    t.integer "page_number",     null: false
    t.integer "access",          null: false
  end

  add_index "sections", ["document_id"], name: "index_sections_on_document_id", using: :btree

  create_table "security_keys", force: :cascade do |t|
    t.string  "securable_type", limit: 40, null: false
    t.integer "securable_id",              null: false
    t.string  "key",            limit: 40
  end

  create_table "upload_mailboxes", force: :cascade do |t|
    t.integer  "membership_id",                         null: false
    t.string   "sender",        limit: 255,             null: false
    t.string   "recipient",     limit: 255,             null: false
    t.integer  "upload_count",              default: 0
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_foreign_key "project_organizations", "organizations"
  add_foreign_key "project_organizations", "projects"
end
