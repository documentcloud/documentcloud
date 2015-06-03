class CreateVerficationRequests < ActiveRecord::Migration
  def change
    create_table :verfication_requests do |t|

      t.timestamps
      t.string  "requester_email"
      t.string  "requester_first_name"
      t.string  "requester_last_name"
      t.string  "requester_notes"
      t.string  "organization_name"
      t.string  "organization_url"
      t.string  "approver_email"
      t.string  "approver_first_name"
      t.string  "approver_last_name"
      t.string  "country"
      t.string  "display_language"
      t.string  "document_language"
      t.string  "verfication_notes"
      t.integer "status"
      t.boolean "agreed_to_terms"
      t.boolean "authorized_posting"
      t.string  "signup_key"
      t.integer "account_id"
    end
  end
end
