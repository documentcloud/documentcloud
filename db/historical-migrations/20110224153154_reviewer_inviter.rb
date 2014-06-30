class ReviewerInviter < ActiveRecord::Migration
  def self.up
    create_table "document_reviewer_inviters", :force => true do |t|
      t.integer "reviewer_account_id",  :null => false
      t.integer "document_id",          :null => false
      t.integer "inviter_account_id",   :null => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table "document_reviewer_inviters"
  end
end
