class AddRemoteUrlsToDocuments < ActiveRecord::Migration
  def self.up
    change_column :documents, :related_article,     :text
    add_column    :documents, :detected_remote_url, :text
    add_column    :documents, :remote_url,          :text
  end

  def self.down
    change_column :documents, :related_article, :string, :limit => 255
    remove_column :documents, :detected_remote_url
    remove_column :documents, :remote_url
  end
end
