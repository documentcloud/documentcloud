class AddAttributesToProcessingJob < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        add_column :processing_jobs, :action,    :string
        add_column :processing_jobs, :options,   :string
        add_column :processing_jobs, :complete, :boolean, :default => false
      end
      direction.down do
        remove_column :processing_jobs, :action
        remove_column :processing_jobs, :options
        remove_column :processing_jobs, :complete
      end
    end
  end
end
