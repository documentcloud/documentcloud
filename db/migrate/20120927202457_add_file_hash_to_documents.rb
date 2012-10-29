class AddFileHashToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :file_hash, :text, :null => true
    add_index :documents, :file_hash
  end

  def self.down
    add_column :documents, :file_hash
  end

  
end
