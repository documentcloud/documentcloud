module DC
  module Store
    
    # This module contains common methods for using Tokyo Cabinet's table 
    # backend. Classes mixing in this module must implement a +path+ method,
    # returning the desired path to the store on disk.
    module TokyoTyrantTable
                  
      # Opens up the store on disk for writing.
      def open_for_writing
        begin
          store = Rufus::Tokyo::TyrantTable.new('127.0.0.1', port)
          # store = Rufus::Tokyo::Table.new(path, :mode => 'wc', :opts => 'ld')
          result = block_given? ? yield(store) : nil
        ensure
          store.close unless store.nil?
        end
        result
      end
      
      # Opens up the store on disk for reading.
      def open_for_reading
        begin
          store = Rufus::Tokyo::TyrantTable.new('127.0.0.1', port)
          # store = Rufus::Tokyo::Table.new(path, :mode => 'r', :opts => 'ld')
          result = yield(store)
        ensure
          store.close unless store.nil?
        end
        result
      end
      
    end
    
  end
end