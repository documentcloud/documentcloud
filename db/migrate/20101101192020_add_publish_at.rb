class AddPublishAt < ActiveRecord::Migration
  def self.up
    add_column :documents, :publish_at, :timestamp
  end

  def self.down
    remove_column :documents, :publish_at
  end
end
