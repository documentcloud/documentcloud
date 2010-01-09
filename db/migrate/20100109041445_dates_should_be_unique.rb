# This is a one-way migration.

class DatesShouldBeUnique < ActiveRecord::Migration
  def self.up
    MetadataDate.destroy_all
    remove_index "metadata_dates", :name => "index_metadata_dates_on_document_id"
    add_index "metadata_dates", ["document_id", "date"], :unique => true, :name => "index_metadata_dates_on_document_id_and_date"
    # Okay because there's not very many documents yet.
    Document.all.each do |doc|
      puts doc.title
      MetadataDate.refresh(doc); doc.save!
    end
  end

  def self.down
    remove_index "metadata_dates", :name => "index_metadata_dates_on_document_id_and_date"
    add_index "metadata_dates", "document_id", :name => "index_metadata_dates_on_document_id"
  end
end
