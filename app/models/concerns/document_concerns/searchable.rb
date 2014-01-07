module DocumentConcerns
  module Searchable
    extend ActiveSupport::Concern

    module ClassMethods
      # Main document search method -- handles queries.
      def search(query, options={})
        query = DC::Search::Parser.new.parse(query) if query.is_a? String
        query.run(options)
      end
    end

    def reindex_all!(access=nil)
      Page.refresh_page_map(self)
      EntityDate.reset(self)
      pages = self.reload.pages
      Sunspot.index pages
      Sunspot.commit
      reprocess_entities if calais_id
      upload_text_assets(pages, access)
      self.access = access if access
      self.save!
    end


    included do
      # The definition of the Solr search index. Via sunspot-rails.
      searchable do

        # Full Text...
        text :title, :default_boost => 2.0
        text :source
        text :description
        text :full_text do
          self.combined_page_text
        end

        # Attributes...
        string  :title
        string  :source
        string  :language
        time    :created_at
        boolean :published, :using => :published?
        integer :id
        integer :account_id
        integer :organization_id
        integer :access
        integer :page_count
        integer :hit_count
        integer :public_note_count
        integer :project_ids, :multiple => true do
          self.project_memberships.map {|m| m.project_id }
        end

        # Entities...
        # DC::ENTITY_KINDS.each do |entity|
        #   text(entity) { self.entity_values(entity) }
        #   string(entity, :multiple => true) { self.entity_values(entity) }
        # end

        # Data...
        dynamic_string :data do
          self.docdata ? self.docdata.data.symbolize_keys : {}
        end
      end
    end


  end
end