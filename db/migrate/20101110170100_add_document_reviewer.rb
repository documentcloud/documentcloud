class AddDocumentReviewer < ActiveRecord::Migration
  def self.up
    create_table "document_reviewers", :force => true do |t|
      t.integer "account_id",  :null => false
      t.integer "document_id", :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table "document_reviewers"
  end
end
