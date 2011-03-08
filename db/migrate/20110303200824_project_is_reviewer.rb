class ProjectIsReviewer < ActiveRecord::Migration
  def self.up
    projects = Project.find(:all, :conditions => ["reviewer_document_id IS NOT NULL"])
    add_column :projects, :hidden, :boolean, :default => false, :null => false
    remove_column :projects, :reviewer_document_id
    projects.each {|p| p.update_attributes :hidden => true }
  end

  def self.down
    remove_column :projects, :hidden
    add_column :projects, :reviewer_document_id, :integer
  end
end
