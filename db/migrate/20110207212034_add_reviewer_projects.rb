class AddReviewerProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :reviewer_document_id, :integer
    change_column :projects, :title, :string, :null => true
  end

  def self.down
    remove_column :projects, :reviewer_document_id
  end
end
