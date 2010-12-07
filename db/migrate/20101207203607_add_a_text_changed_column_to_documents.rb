class AddATextChangedColumnToDocuments < ActiveRecord::Migration
  def self.up
    add_column "documents", "text_changed", :boolean, :default => false, :null => false
  end

  def self.down
    remove_column "documents", "text_changed"
  end
end
