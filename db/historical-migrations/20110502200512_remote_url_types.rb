class RemoteUrlTypes < ActiveRecord::Migration
  
  def self.connection
    RemoteUrl.connection
  end

  def self.up
    add_column :remote_urls, 'note_id', :integer, :null => true
    add_column :remote_urls, 'search_query', :string, :null => true
    change_column :remote_urls, 'document_id', :integer, :null => true
  end

  def self.down
    remove_column :remote_urls, 'note_id'
    remove_column :remote_urls, 'search_query'
    change_column :remote_urls, 'document_id', :integer, :null => false
  end
end
