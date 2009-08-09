module DC
  module Stores
    
    # This module contains common methods for using Tokyo Cabinet's table 
    # backend. Classes mixing in this module must implement a +path+ method,
    # returning the desired path to the store on disk.
    module TokyoCabinetTable
      
      protected
            
      # Opens up the store on disk for writing.
      def open_for_writing
        store = Rufus::Tokyo::Table.new(path, :mode => 'wc', :opts => 'ld')
        result = yield(store)
        store.close
        result
      end
      
      # Opens up the store on disk for reading.
      def open_for_reading
        store = Rufus::Tokyo::Table.new(path, :mode => 'r', :opts => 'ld')
        result = yield(store)
        store.close
        result
      end
      
    end
    
  end
end