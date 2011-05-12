class DropFullText < ActiveRecord::Migration
  def self.up
    remove_index "full_text", :name => "index_full_text_on_document_id"
    drop_table :full_text    
  end

  def self.down
    # This migration is irreversible.
  end
end
