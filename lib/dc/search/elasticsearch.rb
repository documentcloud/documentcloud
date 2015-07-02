require 'elasticsearch/persistence'

module DC
  module Search
    def self.repository
      @@repository ||= Elasticsearch::Persistence::Repository.new
    end
    
    module ElasticSearch
      def self.clear
        DC::Search.repository.client.indices.delete(index: '_all')
      end
      
      class Query
        def initialize(options={})
          @query = nil
        end
      end
    end
  end
end

