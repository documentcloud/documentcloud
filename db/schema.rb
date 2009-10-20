# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091020171535) do

  create_table "accounts", :force => true do |t|
    t.integer "organization_id", :null => false
    t.string  "first_name",      :null => false
    t.string  "last_name",       :null => false
    t.string  "email",           :null => false
    t.string  "hashed_password"
  end

  add_index "accounts", ["email"], :name => "index_accounts_on_email", :unique => true
  add_index "accounts", ["organization_id"], :name => "fk_organization_id"

  create_table "app_constants", :force => true do |t|
    t.string "key"
    t.string "value"
  end

  create_table "organizations", :force => true do |t|
    t.string "name", :null => false
    t.string "slug", :null => false
  end

  add_index "organizations", ["name"], :name => "index_organizations_on_name", :unique => true
  add_index "organizations", ["slug"], :name => "index_organizations_on_slug", :unique => true

  create_table "saved_searches", :force => true do |t|
    t.integer "account_id", :null => false
    t.string  "query",      :null => false
  end

  add_index "saved_searches", ["account_id"], :name => "index_saved_searches_on_account_id"

  create_table "security_keys", :force => true do |t|
    t.string  "securable_type"
    t.integer "securable_id",   :null => false
    t.string  "key"
  end

end
