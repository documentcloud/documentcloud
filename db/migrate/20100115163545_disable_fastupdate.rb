class DisableFastupdate < ActiveRecord::Migration
  extend DC::Store::MigrationHelpers

  def self.up
    remove_full_text_index('documents', 'title')
    remove_full_text_index('documents', 'source')
    remove_full_text_index('full_text', 'text')
    remove_full_text_index('pages', 'text')
    remove_full_text_index('metadata', 'value')
    remove_full_text_index('annotations', 'content')

    add_full_text_index('documents', 'title')
    add_full_text_index('documents', 'source')
    add_full_text_index('full_text', 'text')
    add_full_text_index('pages', 'text')
    add_full_text_index('metadata', 'value')
    add_full_text_index('annotations', 'content')
  end

  def self.down
  end
end
