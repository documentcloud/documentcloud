class AddRemoteUrlToDocument < ActiveRecord::Migration
  def self.up
    add_column :documents, :remote_url, :string
  end

  def self.down
    remove_column :documents, :remote_url
  end
end
