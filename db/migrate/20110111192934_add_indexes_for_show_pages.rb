class AddIndexesForShowPages < ActiveRecord::Migration
  def self.up
    # Entity indexes.
    execute "create index index_entities_on_value on entities (lower(value));"

    # Page indexes.
    remove_index :pages, :name => "index_pages_on_document_id_and_page_number"
    add_index :pages, ["document_id"], :name => "index_pages_on_document_id"
    add_index :pages, ["page_number"], :name => "index_pages_on_page_number"
    add_index :pages, ["start_offset", "end_offset"], :name => "index_pages_on_start_offset_and_end_offset"
  end

  def self.down
    remove_index :entities, :name => "index_entities_on_value"

    add_index :pages, ["document_id", "page_number"], :name => "index_pages_on_document_id_and_page_number", :unique => true
    remove_index :pages, :name => "index_pages_on_document_id"
    remove_index :pages, :name => "index_pages_on_page_number"
    remove_index :pages, :name => "index_pages_on_start_offset_and_end_offset"
  end
end
