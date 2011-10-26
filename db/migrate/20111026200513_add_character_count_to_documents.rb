class AddCharacterCountToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :char_count, :integer, :null => false, :default => 0
    
    # Properly initialize the character counts of all documents.
    Document.find_each do |doc|
      doc.reset_char_count!
    end
  end

  def self.down
    remove_column :documents, :char_count
  end
end
