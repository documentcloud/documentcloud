class ExtendRequestCommentLength < ActiveRecord::Migration
  def up
    change_column :verification_requests, :verification_notes,  :text, :null => true
    change_column :verification_requests, :reference_links,     :text, :null => true
    change_column :verification_requests, :use_case,            :text, :null => true
    change_column :verification_requests, :requester_notes,     :text, :null => true
  end
  def down
    change_column :verification_requests, :verification_notes,  :string, :null => true
    change_column :verification_requests, :reference_links,     :string, :null => true
    change_column :verification_requests, :use_case,            :string, :null => true
    change_column :verification_requests, :requester_notes,     :string, :null => true
  end
end
