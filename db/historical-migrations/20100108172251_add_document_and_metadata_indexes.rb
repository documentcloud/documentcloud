class AddDocumentAndMetadataIndexes < ActiveRecord::Migration
  def self.up
    add_index 'documents', 'account_id', :name => 'index_documents_on_account_id'
    add_index 'documents', 'access',     :name => 'index_documents_on_access'
    add_index 'metadata', 'document_id', :name => 'index_metadata_on_document_id'
    add_index 'metadata', 'kind',        :name => 'index_metadata_on_kind'
  end

  def self.down
    remove_index 'documents', :name => 'index_documents_on_account_id'
    remove_index 'documents', :name => 'index_documents_on_access'
    remove_index 'metadata',  :name => 'index_documents_on_document_id'
    remove_index 'metadata',  :name => 'index_documents_on_kind'
  end
end
