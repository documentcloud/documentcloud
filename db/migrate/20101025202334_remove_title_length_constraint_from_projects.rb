class RemoveTitleLengthConstraintFromProjects < ActiveRecord::Migration
  def self.up
    change_column :projects, :title, :text
  end

  def self.down
    change_column :projects, :title, :string, :limit => 255
  end
end
