class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer "annotation_id",  :null => false
      t.integer "document_id",    :null => false
      t.integer "account_id"
      t.integer "organization_id"
      t.integer "access",         :null => false
      t.text    "author_name",    :length => 90
      t.text    "text",           :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
