class CountReviewersOnDocuments < ActiveRecord::Migration
  def self.up
    add_column  :documents, :document_reviewers_count, :integer, :default => 0, :null => false
    Document.all.each {|d| Document.update_counters d.id, :document_reviewers_count => d.reviewers.count }
  end

  def self.down
    remove_column :documents, :document_reviewers_count
  end
end
