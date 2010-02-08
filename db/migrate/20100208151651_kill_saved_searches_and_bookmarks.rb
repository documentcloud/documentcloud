class KillSavedSearchesAndBookmarks < ActiveRecord::Migration
  def self.up
    drop_table 'saved_searches'
    drop_table 'bookmarks'
  end

  def self.down
  end
end
