require 'elasticsearch/persistence'

module DC
  module Search
    module Repository
      class Document
        include Elasticsearch::Persistence::Repository
        client Elasticsearch::Client.new hosts: DC::SECRETS['elasticsearch_hosts'], log: true
        klass ::Document
        index "document_#{Rails.env}"
        
        def initialize(options={})
          @fields = klass.attribute_names
        end
        
        def serialize(document)
          attributes = document.attributes.clone.merge({
            :full_text   => DC::Search.clean_text(document.combined_page_text),
            :project_ids => document.project_memberships.map {|m| m.project_id },
            :data        => document.docdata ? self.docdata.data.symbolize_keys : {}
          })
        end
        
        # DC::Search.repository(Document).save(Document.first)
        # DC::Search.repository(Document).find(Document.first.id)
        # DC::Search.repository(Document).search(query: q, fields: ::Document.attribute_names)
        
        def deserialize(document)
          attrs = if document['_source']
            document['_source'].select{ |k,v| klass.attribute_names.include? k }
          elsif document['fields']
            Hash[document['fields'].map do |field,values| 
              raise ArgumentError if !values.kind_of?(Array) or values.size > 1
              [field, values.first]
            end]
          end
          klass.new attrs
        end
      end

      class Page
        include Elasticsearch::Persistence::Repository
        client Elasticsearch::Client.new hosts: DC::SECRETS['elasticsearch_hosts'], log: true

        klass ::Page
        index "page_#{Rails.env}"
      end
      
      class Note
        include Elasticsearch::Persistence::Repository
        client Elasticsearch::Client.new hosts: DC::SECRETS['elasticsearch_hosts'], log: true

        klass ::Annotation
        index "note_#{Rails.env}"
      end
    end
    
    def self.repository(key)
      @@repositories ||= {}
      case key.to_s
      when 'Document'
        @@repositories[key.to_s] ||= DC::Search::Repository::Document.new
      when 'Page'
        @@repositories[key.to_s] ||= DC::Search::Repository::Page.new
      when 'Annotation'
        @@repositories[key.to_s] ||= DC::Search::Repository::Note.new
      else
        raise ArgumentError, ""
      end
    end
    
    module ElasticSearch
      def self.clear
        DC::Search.repository.client.indices.delete(index: '_all')
      end
    end
  end
end

