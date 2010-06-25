class AddDefaultCollaborations < ActiveRecord::Migration
  def self.up
    Project.all.each {|project| project.create_default_collaboration }
  end

  def self.down
  end
end
