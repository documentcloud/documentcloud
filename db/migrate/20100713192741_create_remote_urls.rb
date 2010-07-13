class CreateRemoteURLs < ActiveRecord::Migration
  def self.up
    create_table :remote_urls do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :remote_urls
  end
end
