class RemoveLengthLimitationOnDescriptions < ActiveRecord::Migration
  def self.up
    change_column :documents, :description, :text
  end

  def self.down
    change_column :documents, :description, :string, :limit => 255
  end
end
