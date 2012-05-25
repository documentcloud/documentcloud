class MoveNotesToCommenters < ActiveRecord::Migration
  def self.up
    add_column :annotations, :commenter_id, :integer, :null => false
    Annotation.all(:order=>'id asc').each do |note|
      print "\rUpdating note #{note.id}:"
      note.update_attributes(:commenter_id => note.account_id)
      print "Done"
    end
    puts
  end

  def self.down
    remove_column :annotations, :commenter_id
  end
end
