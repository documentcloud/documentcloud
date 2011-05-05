class RemoteUrlTypes < ActiveRecord::Migration

  def self.up
    ActiveRecord::Base.establish_connection ANALYTICS_DB
    add_column :remote_urls, 'note_id', :integer, :null => true
    add_column :remote_urls, 'search_query', :string, :null => true
    change_column :remote_urls, 'document_id', :integer, :null => true
    ActiveRecord::Base.establish_connection MAIN_DB
  end

  def self.down
    ActiveRecord::Base.establish_connection ANALYTICS_DB
    remove_column :remote_urls, 'note_id'
    remove_column :remote_urls, 'search_query'
    change_column :remote_urls, 'document_id', :integer, :null => false
    ActiveRecord::Base.establish_connection MAIN_DB
  end
end
