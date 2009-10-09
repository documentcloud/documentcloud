module DC

  # Mapping of access levels to integers, for efficient storage/querying.
  module Access
    
    DELETED       = 0
    PRIVATE       = 1
    ORGANIZATION  = 2
    EXCLUSIVE     = 3
    PUBLIC        = 4
    
  end
  
end