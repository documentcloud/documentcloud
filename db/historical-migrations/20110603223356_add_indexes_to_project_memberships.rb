class AddIndexesToProjectMemberships < ActiveRecord::Migration
  def self.up
    add_index :project_memberships, ['document_id'], :name => 'index_project_memberships_on_document_id'
    add_index :project_memberships, ['project_id'],  :name => 'index_project_memberships_on_project_id'
  end

  def self.down
    remove_index :project_memberships, :name => 'index_project_memberships_on_document_id'
    remove_index :project_memberships, :name => 'index_project_memberships_on_project_id'
  end
end
