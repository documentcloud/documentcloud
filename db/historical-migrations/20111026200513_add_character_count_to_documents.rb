class AddCharacterCountToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :char_count, :integer, :null => false, :default => 0
    
    # Properly initialize the character counts of all documents.
    Document.connection.execute <<-EOS
      update documents 
      set char_count = 1 + coalesce((select max(end_offset) from pages 
        where pages.document_id = documents.id), 0)
      where char_count = 0
    EOS
  end

  def self.down
    remove_column :documents, :char_count
  end
end
