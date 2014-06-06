# Keep in sync w/ model/status.js

module DC
  # DC::Status specifies the values for a Document's state machine.
  #   A Document's state machine is used to ensure that a document is
  #   viewable as quickly and early as possible, while guaranteeing that
  #   a document is protected from concurrency issues.
  module Status
    ERROR       = 0 # The document has encountered an error during processing
    UNAVAILABLE = 1 # The document is undergoing processing that blocks any other use
    VIEWABLE    = 2 # The document is viewable but unavailable for other processing
    AVAILABLE   = 3 # The document is viewable and available for processing
    
    STATUS_MAP = {
      :error       => ERROR,
      :unavailable => UNAVAILABLE,
      :viewable    => VIEWABLE,
      :available   => AVAILABLE
    }
    
    STATUS_NAMES = STATUS_MAP.invert

    def available?
      self.status == AVAILABLE
    end
    
    def unavailable?
      self.status == UNAVAILABLE
    end
    
    def viewable?
      [AVAILABLE, VIEWABLE].include? self.status
    end
    
    # REMOVE AFTER STATUS IS MIGRATED
    FROM_ACCESS = Hash.new(AVAILABLE)
    FROM_ACCESS[DC::Access::ERROR]   = ERROR
    FROM_ACCESS[DC::Access::PENDING] = UNAVAILABLE

    # REMOVE AFTER STATUS IS MIGRATED
    # extend relevent model calsses with this
    module Migration
      def update_all_statuses
        self.where(:access=>DC::Access::ERROR).update_all(:status => DC::Status::ERROR)
        self.where(:access=>DC::Access::PENDING).update_all(:status => DC::Status::UNAVAILABLE)
        self.where("access not in (?)", [DC::Access::PENDING, DC::Access::ERROR]).update_all(:status => DC::Status::AVAILABLE)
      end
    end
  end
end
