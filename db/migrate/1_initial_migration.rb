# This is a "rollup" of all migrations before Jun 30, 2014
# The old migration files are stored in ../historical-migrations

class InitialMigration < ActiveRecord::Migration

  def change

    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    # hstore extension creation being dozne in setup_database.sh
    #enable_extension "hstore"

    create_table "accounts", force: true do |t|
      t.string   "first_name",        limit: 40
      t.string   "last_name",         limit: 40
      t.string   "email",             limit: 100
      t.string   "hashed_password"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.hstore   "identities"
      t.string   "language",          limit: 3,   default: "eng"
      t.string   "document_language", limit: 3,   default: "eng"
    end

    add_index "accounts", ["email"], name: "index_accounts_on_email", unique: true, using: :btree
    add_index "accounts", ["identities"], name: "index_accounts_on_identites", using: :gin

    create_table "annotations", force: true do |t|
      t.integer  "organization_id",     null: false
      t.integer  "account_id",          null: false
      t.integer  "document_id",         null: false
      t.integer  "page_number",         null: false
      t.integer  "access",              null: false
      t.text     "title",               null: false
      t.text     "content"
      t.string   "location",            limit: 40
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "moderation_approval"
    end

    add_index "annotations", ["document_id"], name: "index_annotations_on_document_id", using: :btree

    create_table "app_constants", force: true do |t|
      t.string "key"
      t.string "value"
    end

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

    create_table "entities", force: true do |t|
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

    create_table "entity_dates", force: true do |t|
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

    create_table "memberships", force: true do |t|
      t.integer "organization_id",                 null: false
      t.integer "account_id",                      null: false
      t.integer "role",                            null: false
      t.boolean "default",         default: false
      t.boolean "concealed",       default: false
    end

    add_index "memberships", ["account_id"], name: "index_memberships_on_account_id", using: :btree
    add_index "memberships", ["organization_id"], name: "index_memberships_on_organization_id", using: :btree

    create_table "organizations", force: true do |t|
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

    create_table "pages", force: true do |t|
      t.integer "organization_id", null: false
      t.integer "account_id",      null: false
      t.integer "document_id",     null: false
      t.integer "access",          null: false
      t.integer "page_number",     null: false
      t.text    "text",            null: false
      t.integer "start_offset"
      t.integer "end_offset"
    end

    add_index "pages", ["document_id"], name: "index_pages_on_document_id", using: :btree
    add_index "pages", ["page_number"], name: "index_pages_on_page_number", using: :btree
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
      t.integer "document_id"
    end

    add_index "processing_jobs", ["account_id"], name: "index_processing_jobs_on_account_id", using: :btree

    create_table "project_memberships", force: true do |t|
      t.integer "project_id",  null: false
      t.integer "document_id", null: false
    end

    add_index "project_memberships", ["document_id"], name: "index_project_memberships_on_document_id", using: :btree
    add_index "project_memberships", ["project_id"], name: "index_project_memberships_on_project_id", using: :btree

    create_table "projects", force: true do |t|
      t.integer "account_id"
      t.string  "title"
      t.text    "description"
      t.boolean "hidden",      default: false, null: false
    end

    add_index "projects", ["account_id"], name: "index_labels_on_account_id", using: :btree

    create_table "remote_urls", force: true do |t|
      t.integer "document_id",             null: false
      t.string  "url",                     null: false
      t.integer "hits",        default: 0, null: false
    end

    create_table "sections", force: true do |t|
      t.integer "organization_id", null: false
      t.integer "account_id",      null: false
      t.integer "document_id",     null: false
      t.text    "title",           null: false
      t.integer "page_number",     null: false
      t.integer "access",          null: false
    end

    add_index "sections", ["document_id"], name: "index_sections_on_document_id", using: :btree

    create_table "security_keys", force: true do |t|
      t.string  "securable_type", limit: 40, null: false
      t.integer "securable_id",              null: false
      t.string  "key",            limit: 40
    end

  end
end
