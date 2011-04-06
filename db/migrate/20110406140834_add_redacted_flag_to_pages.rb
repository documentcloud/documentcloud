class AddRedactedFlagToPages < ActiveRecord::Migration
  def self.up
    add_column "pages", "redacted", :boolean, :default => false, :null => false
  end

  def self.down
    remove_column "pages", "redacted"
  end
end
