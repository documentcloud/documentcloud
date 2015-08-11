class OriginalExtension < ActiveRecord::Migration
  def self.up
    add_column :documents, :original_extension, :string, :limit => 255
    Document.connection.execute <<-EOS
      update documents 
      set original_extension = 'pdf'
    EOS
  end

  def self.down
    remove_column :documents, :original_extension
  end
end
