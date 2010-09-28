class RemoveTitleLengthConstraint < ActiveRecord::Migration
  def self.up
    change_column :annotations, :title, :text
  end

  def self.down
    change_column :annotations, :title, :string, :limit => 255
  end
end
