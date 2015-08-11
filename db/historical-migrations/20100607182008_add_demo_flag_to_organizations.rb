class AddDemoFlagToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :demo, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :organizations, :demo
  end
end
