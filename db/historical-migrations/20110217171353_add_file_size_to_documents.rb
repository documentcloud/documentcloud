class AddFileSizeToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :file_size, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :documents, :file_size
  end
end
