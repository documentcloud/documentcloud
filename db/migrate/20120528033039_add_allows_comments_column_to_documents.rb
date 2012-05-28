class AddAllowCommentsColumnToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :allows_comments, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :documents, :allows_comments
  end
end
