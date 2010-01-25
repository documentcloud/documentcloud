class AddTags < ActiveRecord::Migration
  extend DC::Store::MigrationHelpers

  def self.up
    create_table "tags", :force => true do |t|
      t.integer "account_id",   :null => false
      t.string  "title",        :null => false
    end

    foreign_key "tags", "accounts"

    create_table "taggings", :force => true do |t|
      t.integer "tag_id",         :null => false
      t.string  "taggable_type",  :null => false, :limit => 40
      t.integer "taggable_id"
    end

    foreign_key "taggings", "tags"
  end

  def self.down
    drop_foreign_key "taggings", "tags"
    drop_foreign_key "tags", "accounts"
    drop_table "taggings"
    drop_table "tags"
  end
end
