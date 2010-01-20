class ChangeLabelsToProjects < ActiveRecord::Migration
  def self.up
    rename_table 'labels', 'projects'
  end

  def self.down
    rename_table 'projects', 'labels'
  end
end
