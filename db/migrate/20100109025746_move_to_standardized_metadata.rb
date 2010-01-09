# This migration is non-reversible...

class MoveToStandardizedMetadata < ActiveRecord::Migration
  extend DC::Store::MigrationHelpers

  def self.up
    execute "delete from metadata where kind not in ('company', 'organization', 'facility', 'natural_feature', 'city', 'country', 'industry_term', 'person', 'province_or_state', 'published_medium', 'technology', 'category', 'date');"
    execute "update metadata set kind = 'organization' where kind = 'company';"
    execute "update metadata set kind = 'place' where kind = 'facility';"
    execute "update metadata set kind = 'place' where kind = 'natural_feature';"
    execute "update metadata set kind = 'term' where kind = 'industry_term';"
    execute "update metadata set kind = 'state' where kind = 'province_or_state';"
    execute "update metadata set kind = 'publication' where kind = 'published_medium';"
  end

  def self.down
  end
end
