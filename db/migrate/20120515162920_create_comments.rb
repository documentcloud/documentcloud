class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer "annotation_id",  :null => false
      t.integer "document_id",    :null => false
      t.integer "commenter_id"
      t.text    "text",           :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
