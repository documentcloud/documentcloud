class ProjectIsReviewer < ActiveRecord::Migration
  def self.up
    ids = Project.where("reviewer_document_id IS NOT NULL").pluck(:id).to_a
    add_column :projects, :hidden, :boolean, :default => false, :null => false
    remove_column :projects, :reviewer_document_id
    Project.where(id: ids).update_all(hidden: true)
  end

  def self.down
    remove_column :projects, :hidden
    add_column :projects, :reviewer_document_id, :integer
  end
end
