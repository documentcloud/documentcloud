ActiveRecord::Schema.define(:version => 0) do
  extend DC::Store::MigrationHelpers
  
  disable_foreign_keys
  
  create_table "organizations", :force => true do |t|
    t.string  "name", :null => false
    t.string  "slug", :null => false
  end
  
  add_index 'organizations', 'name', :unique => true
  add_index 'organizations', 'slug', :unique => true
  
  create_table "accounts", :force => true do |t|
    t.integer "organization_id",  :null => false
    t.string  "first_name",       :null => false
    t.string  "last_name",        :null => false
    t.string  "email",            :null => false
    t.string  "hashed_password",  :null => false
  end
  
  foreign_key 'accounts', 'organizations'
  add_index 'accounts', 'email', :unique => true
  
  enable_foreign_keys
  
end