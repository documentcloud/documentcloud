class MoveNotesToCommenters < ActiveRecord::Migration
  def self.up
    add_column :annotations, :commenter_id, :integer
    notes = Annotation.all
    notes.each{ |n| n.update_attributes(:commenter_id => n.account_id) }
  end

  def self.down
    remove :annotations, :commenter_id
  end
end
