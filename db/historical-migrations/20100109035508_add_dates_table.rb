class AddDatesTable < ActiveRecord::Migration
  extend DC::Store::MigrationHelpers

  def self.up
    create_table "metadata_dates", :force => true do |t|
      t.integer "organization_id",  :null => false
      t.integer "account_id",       :null => false
      t.integer "document_id",      :null => false
      t.integer "access",           :null => false
      t.date    "date",             :null => false
    end

    add_index "metadata_dates", "document_id", :name => "index_metadata_dates_on_document_id"

    # Okay because there's not very many documents yet.
    Document.all.each do |doc|
      puts doc.title
      MetadataDate.reset(doc); doc.save!
    end
  end

  def self.down
    remove_index "metadata_dates", :name => "index_metadata_dates_on_document_id"
    drop_table "metadata_dates"
  end
end
