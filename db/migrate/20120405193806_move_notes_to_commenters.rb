class MoveNotesToCommenters < ActiveRecord::Migration
  def self.up
    rename_column :annotations, :account_id, :commenter_id
  end

  def self.down
    rename_column :annotations, :commenter_id, :account_id
  end
end
