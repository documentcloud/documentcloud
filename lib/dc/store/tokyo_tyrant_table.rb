module DC
  module Store
    
    # This module contains common methods for using Tokyo Cabinet's table 
    # backend. Classes mixing in this module must implement a +path+ method,
    # returning the desired path to the store on disk.
    module TokyoTyrantTable
      
      # Convenience method to open up a table for reading and run a query on it.
      def query
        open_for_reading {|store| store.query {|query| yield query } }
      end
      
      # Convenience to open up a table for reading and run a search over it.
      def search(type, full_records = true)
        open_for_reading do |store|
          queries = yield store
          queries << false unless full_records
          store.search(type, *queries)
        end
      end
                  
      # Opens up the store on disk for writing.
      def open_for_writing
        begin
          store = Rufus::Tokyo::TyrantTable.new(@host, @port)
          result = block_given? ? yield(store) : nil
        ensure
          store.close unless store.nil?
        end
        result
      end
      
      # Opens up the store on disk for reading.
      def open_for_reading
        begin
          store = Rufus::Tokyo::TyrantTable.new(@host, @port)
          result = yield(store)
        ensure
          store.close unless store.nil?
        end
        result
      end
      
    end
    
  end
end