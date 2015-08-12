class EmpowerProcessingJob < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        add_column :processing_jobs, :action,   :string
        add_column :processing_jobs, :options,  :string
        add_column :processing_jobs, :complete, :boolean, :default => false
        
        add_index :processing_jobs, :action,         :name => "index_processing_jobs_on_action"
        add_index :processing_jobs, :cloud_crowd_id, :name => "index_processing_jobs_on_cloud_crowd_id"
        add_index :processing_jobs, :document_id,    :name => "index_processing_jobs_on_document_id"
      end

      direction.down do
        remove_index :processing_jobs, :name => "index_processing_jobs_on_action"
        remove_index :processing_jobs, :name => "index_processing_jobs_on_cloud_crowd_id"
        remove_index :processing_jobs, :name => "index_processing_jobs_on_document_id"
        
        remove_column :processing_jobs, :action
        remove_column :processing_jobs, :options
        remove_column :processing_jobs, :complete
      end
    end
  end
end
