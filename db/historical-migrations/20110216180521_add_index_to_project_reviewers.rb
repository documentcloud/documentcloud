class AddIndexToProjectReviewers < ActiveRecord::Migration
  def self.up
    add_index "projects", ["reviewer_document_id"], :name => "fk_reviewer_document_id"
  end

  def self.down
    remove_index "projects", :name => "fk_reviewer_document_id"
  end
end
