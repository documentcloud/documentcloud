# Our DocumentCloud-specific exception classes belong in here.

module DC
  
  class Error < RuntimeError; end
  
  class DocumentNotFound < DC::Error; end
  
end