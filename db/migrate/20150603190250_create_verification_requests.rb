class CreateVerificationRequests < ActiveRecord::Migration
  def up
    create_table :verification_requests do |t|

      t.timestamps
      t.string  "requester_email"
      t.string  "requester_first_name"
      t.string  "requester_last_name"
      t.string  "requester_notes",      :length => 255,    :null => true
      t.string  "organization_name",    :length => 100
      t.string  "organization_slug",    :length => 100,    :null => true
      t.string  "organization_url",     :length => 255,    :null => true
      t.string  "approver_email",       :length => 255
      t.string  "approver_first_name"
      t.string  "approver_last_name"
      t.string  "country",                                 :null => true
      t.string  "display_language"
      t.string  "document_language"
      t.string  "verification_notes",                      :null => true
      t.integer "status",               :default => 1
      t.boolean "agreed_to_terms",      :default => false
      t.boolean "authorized_posting",   :default => false
      t.string  "signup_key"
      t.integer "account_id"
    end
  end

  def down
    drop_table :verification_requests
  end
end
