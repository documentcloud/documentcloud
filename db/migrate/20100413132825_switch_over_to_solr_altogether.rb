class SwitchOverToSolrAltogether < ActiveRecord::Migration
  extend DC::Store::MigrationHelpers

  def self.up
    # Index with Solr.
    Page.find_in_batches(:conditions => ['true']) do |pages|
      Sunspot.index(pages)
    end

    # Commit the updates.
    Sunspot.commit

    # Remove the Postgres indexes.
    remove_full_text_index :annotations, :content
    remove_full_text_index :documents,   :title
    remove_full_text_index :documents,   :source
    remove_full_text_index :full_text,   :text
    remove_full_text_index :pages,       :text

    # Has to be removed by hand because the name of the table has changed.
    execute "drop index metadata_value_fti;"
    execute "drop trigger metadata_value_vector_update on entities;"
    remove_column :entities, :metadata_value_vector
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
