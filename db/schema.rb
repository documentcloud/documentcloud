ActiveRecord::Schema.define(:version => 0) do
  
  create_table "organizations", :force => true do |t|
    t.string "name", :null => false
    t.string "slug", :null => false
  end
  
  create_table "accounts", :force => true do |t|
    t.string  "first_name"
    t.string  "last_name"
  end
  
end