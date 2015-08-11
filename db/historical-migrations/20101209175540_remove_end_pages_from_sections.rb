class RemoveEndPagesFromSections < ActiveRecord::Migration
  def self.up
    remove_column :sections, :end_page
    rename_column :sections, :start_page, :page_number
  end

  def self.down
    add_column :sections, :end_page, :integer, :null => false
    rename_column :sections, :page_number, :start_page
  end
end
