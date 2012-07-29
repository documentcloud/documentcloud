class AddAllowsCommentsColumnToDocumentsAndNotes < ActiveRecord::Migration
  def self.up
    add_column :documents,   :comment_access, :integer, :null => false, :default => 1
    add_column :annotations, :comment_access, :integer, :null => false, :default => 1
  end

  def self.down
    remove_column :documents,   :comment_access
    remove_column :annotations, :comment_access
  end
end
