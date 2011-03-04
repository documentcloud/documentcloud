class ChangeToReviewerCount < ActiveRecord::Migration
  def self.up
    rename_column :documents, :document_reviewers_count, :reviewer_count
  end

  def self.down
    rename_column :documents, :reviewer_count, :document_reviewers_count
  end
end
