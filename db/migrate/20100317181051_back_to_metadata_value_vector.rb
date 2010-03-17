class BackToMetadataValueVector < ActiveRecord::Migration
  def self.up
    rename_column :entities, :entity_value_vector, :metadata_value_vector
  end

  def self.down
    rename_column :entities, :metadata_value_vector, :entity_value_vector
  end
end
