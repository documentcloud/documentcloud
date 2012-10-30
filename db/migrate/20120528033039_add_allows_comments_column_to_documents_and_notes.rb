class AddAllowsCommentsColumnToDocumentsAndNotes < ActiveRecord::Migration
  def self.up
    add_column :documents,      :comment_access, :integer
    add_column :annotations,    :comment_access, :integer
    
    Document.find_each do |document|
      document.update_attribute(:comment_access, document.access)
    end
    
    Annotation.find_each do |note|
      note.update_attribute(:comment_access, note.access)
    end
    
    change_column :documents,   :comment_access, :integer, :null => true
    change_column :annotations, :comment_access, :integer, :null => true
  end

  def self.down
    remove_column :documents,   :comment_access
    remove_column :annotations, :comment_access
  end
end
