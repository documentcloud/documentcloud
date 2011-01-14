class AddPublicNoteCountToDocuments < ActiveRecord::Migration
  def self.up
    add_column 'documents', 'public_note_count', :integer, :null => false, :default => 0
    add_index 'documents', ['public_note_count'], :name => 'index_documents_on_public_note_count'
  end

  def self.down
    remove_index 'documents', :name => 'index_documents_on_public_note_count'
    remove_column 'documents', 'public_note_count'
  end
end
