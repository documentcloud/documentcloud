class MoveMetadataToEntities < ActiveRecord::Migration
  def self.up
    rename_table :metadata,       :entities
    rename_table :metadata_dates, :entity_dates
    rename_column :entities, :metadata_value_vector, :entity_value_vector
  end

  def self.down
    rename_column :entities, :entity_value_vector, :metadata_value_vector
    rename_table :entities,     :metadata
    rename_table :entity_dates, :metadata_dates
  end
end
