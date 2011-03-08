class MakeProjectsOwnerless < ActiveRecord::Migration
  def self.up
    change_column :projects, :account_id, :integer, :null => true
  end

  def self.down
    change_column :projects, :account_id, :integer, :null => false
  end
end
