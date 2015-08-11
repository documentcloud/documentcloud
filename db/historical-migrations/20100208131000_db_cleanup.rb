class DbCleanup < ActiveRecord::Migration
  extend DC::Store::MigrationHelpers

  def self.up
    # Remove unused tags table.
    drop_foreign_key "taggings", "tags"
    drop_foreign_key "tags", "accounts"
    drop_table "taggings"
    drop_table "tags"

    create_table "project_memberships", :force => true do |t|
      t.integer "project_id",   :null => false
      t.integer "document_id",  :null => false
    end

    Project.all.each do |project|
      project.split_document_ids.each do |doc_id|
        project.project_memberships.create(:document_id => doc_id)
      end
    end

    remove_column 'projects', 'document_ids'
  end

  def self.down
    add_column 'projects', 'document_ids', :text

    drop_table "project_memberships"

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

end
