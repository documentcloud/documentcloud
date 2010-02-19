# This migration is non-reversible.

class RemoveMetadataForPublicationsAndTechnologies < ActiveRecord::Migration
  def self.up
    execute "delete from metadata where kind in ('publication', 'technology');"
  end

  def self.down
  end
end
