class RemoveRemoteUrlFromDocuments < ActiveRecord::Migration
  def self.up
    remove_column :documents, :remote_url
  end

  def self.down
    add_column :documents, :remote_url, :string
  end
end
