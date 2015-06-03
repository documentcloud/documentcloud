class CreateVerificationRequests < ActiveRecord::Migration
  def up
    create_table :verification_requests do |t|
      
      t.timestamps
      t.string  "requester_email",                         :null => false
      t.string  "requester_first_name",                    :null => false
      t.string  "requester_last_name",                     :null => false
      t.string  "requester_notes",      :length => 255
      t.string  "organization_name",    :length => 255,    :null => false
      t.string  "organization_slug",    :length => 255,    :null => false
      t.string  "organization_url",     :length => 255     
      t.string  "approver_email",       :length => 255,    :null => false
      t.string  "approver_first_name",                     :null => false
      t.string  "approver_last_name",                      :null => false
      t.string  "country"                                  
      t.string  "display_language",                        :null => false
      t.string  "document_language",                       :null => false
      t.string  "verification_notes"
      t.integer "status",               :default => 1,     :null => false
      t.boolean "agreed_to_terms",      :default => false, :null => false
      t.boolean "authorized_posting",   :default => false, :null => false
      t.string  "signup_key",                              :null => false
      t.integer "account_id" 
    end
  end
  
  def down
    drop_table :verification_requests
  end
end
