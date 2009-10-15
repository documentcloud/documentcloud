module DC
  module Store
    
    # Stores full text for a document, indexed by document_id, in a full text
    # search index (appropriate choices would be Tokyo Dystopia, Solr, 
    # Xapian, and perhaps Sphinx).
    class FullTextStore
      
      INDEX_PATH  = "#{RAILS_ROOT}/db/sphinx"
      CONFIG_PATH = "#{RAILS_ROOT}/config/sphinx.conf"
      PID_PATH    = "#{RAILS_ROOT}/tmp/pids/searchd.pid"
      
      def initialize
        ensure_index_folder
      end
      
      # Find the top most relevant results.
      def find(search_text, opts={})
        client            = Riddle::Client.new
        client.limit      = opts[:limit] if opts[:limit]
        existing          = Riddle::Client::Filter.new('access', [DC::Access::PUBLIC])
        client.filters    = [existing]
        client.match_mode = :extended2
        results           = client.query(search_text)
        results[:matches].map {|m| Document.new(:id => m[:doc].to_s(16)) }
      end
      
      def destroy(doc)
        Riddle::Client.new.update('documents', ['access'], doc.integer_id => DC::Access::DELETED)
      end
      
      def update_access(doc)
        Riddle::Client.new.update('documents', ['access'], doc.integer_id => doc.access)
      end
      
      # Tell indexer to re-index all the documents.
      def index_all
        system "indexer -c #{CONFIG_PATH} --all #{rotate_options}"
      end
      
      def index
        system "indexer -c #{CONFIG_PATH} documents_delta #{rotate_options}"
      end
      
      def merge
        system "indexer -c #{CONFIG_PATH} --merge documents documents_delta --merge-dst-range access 1 10 #{rotate_options}"
      end
      
      # Delete the full-text store entirely.
      def delete_database!
        stop_searchd
        FileUtils.rm_r(INDEX_PATH) if File.exists?(INDEX_PATH)
        ensure_index_folder
      end
      
      def start_searchd
        return if searchd_running?
        ensure_index_folder
        Dir["#{INDEX_PATH}/*.spl"].each {|file| File.delete(file) }
        system "searchd --pidfile -c #{CONFIG_PATH}"
      end
      
      def stop_searchd
        return unless searchd_running?
        system "searchd --stop -c #{CONFIG_PATH}"
      end
      
      def searchd_status
        `searchd --status -c #{CONFIG_PATH}`
      end
      
      def searchd_pid
        @searchd_pid ||= File.exists?(PID_PATH) ? File.read(PID_PATH)[/\d+/].to_i : nil
      end
      
      def searchd_running?
        !!searchd_pid && !!Process.kill(0, searchd_pid) rescue false
      end
      
      
      private
      
      def ensure_index_folder
        FileUtils.mkdir_p(INDEX_PATH) unless File.exists?(INDEX_PATH)
      end
      
      def rotate_options
        searchd_running? ? '--rotate' : ''
      end
      
    end
    
  end
end