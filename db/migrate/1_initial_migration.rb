# The base DocumentCloud schema.
class InitialMigration < ActiveRecord::Migration
  extend DC::Store::MigrationHelpers

  def self.up
    create_table "accounts", :force => true do |t|
      t.integer "organization_id", :null => false
      t.string  "first_name",      :null => false, :limit => 40
      t.string  "last_name",       :null => false, :limit => 40
      t.string  "email",           :null => false, :limit => 100
      t.string  "hashed_password"
      t.timestamps
    end

    add_index "accounts", ["email"], :name => "index_accounts_on_email", :unique => true
    add_index "accounts", ["organization_id"], :name => "fk_organization_id"

    create_table "app_constants", :force => true do |t|
      t.string "key"
      t.string "value"
    end

    create_table "documents", :force => true do |t|
      t.integer   "organization_id", :null => false
      t.integer   "account_id",      :null => false
      t.integer   "access",          :null => false
      t.integer   "page_count",      :null => false, :default => 0
      t.string    "title",           :null => false
      t.string    "slug",            :null => false
      t.string    "source"
      t.string    "language",        :limit => 3
      t.string    "summary",         :limit => 255
      t.string    "calais_id",       :limit => 40
      t.date      "publication_date"
      t.timestamps
    end

    create_table "full_text", :force => true do |t|
      t.integer   "organization_id", :null => false
      t.integer   "account_id",      :null => false
      t.integer   "document_id",     :null => false
      t.integer   "access",          :null => false
      t.text      "text",            :null => false
    end

    add_index "full_text", ["document_id"], :name => "index_full_text_on_document_id", :unique => true
    add_full_text_index("full_text", "text")

    create_table "pages", :force => true do |t|
      t.integer   "organization_id",  :null => false
      t.integer   "account_id",       :null => false
      t.integer   "document_id",      :null => false
      t.integer   "access",           :null => false
      t.integer   "page_number",      :null => false
      t.text      "text",             :null => false
    end

    add_index "pages", ["document_id", "page_number"], :name => "index_pages_on_document_id_and_page_number", :unique => true
    add_full_text_index("pages", "text")

    create_table "metadata", :force => true do |t|
      t.integer   "organization_id",  :null => false
      t.integer   "account_id",       :null => false
      t.integer   "document_id",      :null => false
      t.integer   "access",           :null => false
      t.string    "kind",             :null => false, :limit => 40
      t.string    "value",            :null => false
      t.float     "relevance",        :null => false, :default => 0.0
      t.string    "calais_id",                        :limit => 40
      t.text      "occurrences"
    end

    add_full_text_index("metadata", "value")

    create_table "sections", :force => true do |t|
      t.integer   "organization_id",  :null => false
      t.integer   "account_id",       :null => false
      t.integer   "document_id",      :null => false
      t.integer   "access",           :null => false
      t.string    "title",            :null => false
      t.integer   "start_page",       :null => false
      t.integer   "end_page",         :null => false
    end

    add_index "sections", ["document_id"], :name => "index_sections_on_document_id"

    create_table "annotations", :force => true do |t|
      t.integer   "organization_id",  :null => false
      t.integer   "account_id",       :null => false
      t.integer   "document_id",      :null => false
      t.integer   "page_number",      :null => false
      t.integer   "access",           :null => false
      t.string    "title",            :null => false
      t.text      "content"
      t.string    "location",         :limit => 40
      t.timestamps
    end

    add_index "annotations", ["document_id"], :name => "index_annotations_on_document_id"
    add_full_text_index("annotations", "content")

    create_table "processing_jobs", :force => true do |t|
      t.integer "account_id",     :null => false
      t.integer "cloud_crowd_id", :null => false
      t.string  "title",          :null => false
    end

    add_index "processing_jobs", ["account_id"], :name => "index_processing_jobs_on_account_id"

    create_table "labels", :force => true do |t|
      t.integer "account_id",   :null => false
      t.string  "title",        :null => false, :limit => 100
      t.text    "document_ids"
    end

    add_index "labels", ["account_id"], :name => "index_labels_on_account_id"

    create_table "organizations", :force => true do |t|
      t.string "name", :null => false, :limit => 100
      t.string "slug", :null => false, :limit => 100
      t.timestamps
    end

    add_index "organizations", ["name"], :name => "index_organizations_on_name", :unique => true
    add_index "organizations", ["slug"], :name => "index_organizations_on_slug", :unique => true

    create_table "saved_searches", :force => true do |t|
      t.integer "account_id", :null => false
      t.string  "query",      :null => false
    end

    add_index "saved_searches", ["account_id"], :name => "index_saved_searches_on_account_id"

    create_table "bookmarks", :force => true do |t|
      t.integer "account_id",   :null => false
      t.integer "document_id",  :null => false
      t.integer "page_number",  :null => false
      t.string  "title",        :null => false, :limit => 100
    end

    add_index "bookmarks", ["account_id"], :name => "index_bookmarks_on_account_id"

    create_table "security_keys", :force => true do |t|
      t.string  "securable_type", :null => false, :limit => 40
      t.integer "securable_id",   :null => false
      t.string  "key",                            :limit => 40
    end
  end

  def self.down
    remove_index "accounts", :name => "index_accounts_on_email"
    remove_index "accounts", :name => "fk_organization_id"
    drop_table "accounts"

    drop_table "app_constants"

    drop_table "documents"

    remove_index "full_text", :name => "index_full_text_on_document_id"
    remove_full_text_index("full_text", "text")
    drop_table "full_text"

    remove_index "pages", :name => "index_pages_on_document_id_and_page_number"
    remove_full_text_index("pages", "text")
    drop_table "pages"

    remove_full_text_index("metadata", "value")
    drop_table("metadata")

    remove_index "sections", :name => "index_sections_on_document_id"
    drop_table "sections"

    remove_index "annotations", :name => "index_annotations_on_document_id"
    remove_full_text_index("annotations", "content")
    drop_table "annotations"

    remove_index "processing_jobs", :name => "index_processing_jobs_on_account_id"
    drop_table "processing_jobs"

    remove_index "labels", :name => "index_labels_on_account_id"
    drop_table "labels"

    remove_index "organizations", :name => "index_organizations_on_name"
    remove_index "organizations", :name => "index_organizations_on_slug"
    drop_table "organizations"

    remove_index "saved_searches", :name => "index_saved_searches_on_account_id"
    drop_table "saved_searches"

    remove_index "bookmarks", :name => "index_bookmarks_on_account_id"
    drop_table "bookmarks"

    drop_table "security_keys"
  end
end
