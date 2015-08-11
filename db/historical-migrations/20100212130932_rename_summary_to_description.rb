class RenameSummaryToDescription < ActiveRecord::Migration
  def self.up
    rename_column :documents, :summary, :description
  end

  def self.down
    rename_column :documents, :description, :summary
  end
end
