class CollaborationCreatorId < ActiveRecord::Migration
  def self.up
    add_column :collaborations, :creator_id, :integer
    drop_table "document_reviewer_inviters"
  end

  def self.down
    remove_column :collaborations, :creator_id
  end
end
