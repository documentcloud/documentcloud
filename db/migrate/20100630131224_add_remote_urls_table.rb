class AddRemoteUrlsTable < ActiveRecord::Migration
  def self.up
    create_table "remote_urls", :force => true do |t|
      t.integer "document_id",  :null => false
      t.string  "url",          :null => false
      t.integer "hits",         :null => false, :default => 0
    end
  end

  def self.down
    drop_table "remote_urls"
  end
end
