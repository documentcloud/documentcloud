class CreateUploadMailboxes < ActiveRecord::Migration
  def change
    create_table :upload_mailboxes do |t|
      t.integer :membership_id, null: false
      t.string  :sender,        limit: 255, null: false
      t.string  :recipient,     limit: 255, null: false
      t.timestamps null: false
    end
  end
end
