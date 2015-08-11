class AddDocumentIdToProcessingJobs < ActiveRecord::Migration
  def self.up
    add_column :processing_jobs, :document_id, :integer
  end

  def self.down
    remove_column :processing_jobs, :document_id
  end
end
