# This migration is a one-way ticket.
class DeleteAllCategoriesMetadata < ActiveRecord::Migration
  def self.up
    execute "delete from metadata where kind = 'category';"
  end

  def self.down
  end
end
