class AddDataToDocuments < ActiveRecord::Migration
  def self.up
    create_table :docdata do |t|
      t.integer :document_id, :null => false
      t.column :data, :hstore
    end
    ActiveRecord::Base.connection.execute "create index index_docdata_on_data on docdata using gin(data);"
  end

  def self.down
    ActiveRecord::Base.connection.execute "drop index index_docdata_on_data;"
    drop_table :docdata
  end
end
