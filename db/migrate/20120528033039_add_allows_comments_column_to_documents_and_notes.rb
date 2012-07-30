class AddAllowsCommentsColumnToDocumentsAndNotes < ActiveRecord::Migration
  def self.up
    add_column :documents,   :comment_access, :integer, :null => false
    add_column :annotations, :comment_access, :integer, :null => false
  end

  def self.down
    remove_column :documents,   :comment_access
    remove_column :annotations, :comment_access
  end
end
