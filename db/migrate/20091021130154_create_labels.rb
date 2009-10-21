class CreateLabels < ActiveRecord::Migration
  def self.up
    create_table "labels", :force => true do |t|
      t.integer "account_id",   :null => false
      t.string  "title",        :null => false
      t.text    "document_ids"
    end
    add_index "labels", ["account_id"], :name => "index_labels_on_account_id"
  end

  def self.down
    drop_table "labels"
  end
end









class AddSavedSearches < ActiveRecord::Migration
  def self.up
    create_table "saved_searches", :force => true do |t|
      t.integer "account_id", :null => false
      t.string  "query",      :null => false
    end
    add_index "saved_searches", ["account_id"], :name => "index_saved_searches_on_account_id"
  end

  def self.down
    drop_table "saved_searches"
  end
end


