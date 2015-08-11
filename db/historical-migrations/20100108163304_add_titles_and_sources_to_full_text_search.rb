class AddTitlesAndSourcesToFullTextSearch < ActiveRecord::Migration
  extend DC::Store::MigrationHelpers

  def self.up
    add_full_text_index('documents', 'title')
    add_full_text_index('documents', 'source')
  end

  def self.down
    remove_full_text_index('documents', 'title')
    remove_full_text_index('documents', 'source')
  end
end
