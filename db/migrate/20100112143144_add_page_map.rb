class AddPageMap < ActiveRecord::Migration
  def self.up
    add_column "pages",           "start_offset", :integer
    add_column "pages",           "end_offset", :integer
    add_column "metadata_dates",  "occurrences", :text

    Document.all.each do |doc|
      puts "Migrating: #{doc.title}"
      MetadataDate.reset(doc)
      Page.refresh_page_map(doc)
    end
  end

  def self.down
    remove_column "pages",          "start_offset"
    remove_column "pages",          "end_offset"
    remove_column "metadata_dates", "occurrences"
  end
end
