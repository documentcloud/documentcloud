module DocumentCloud
  
  # Abstract skeleton of what our Search Backend needs to provide for us.
  # Searches should return at least a document id, along with the relevance of 
  # that document in the context of the search.
  class SearchBackend
        
    # Search DocumentCloud's full-text index.
    def search_full_text(text, limit=10, min_relevance=0.0)
      raise NotImplementedError
    end
    
    # Search DocumentCloud's meta-data index for documents referring to a 
    # given entity (see app/models/entity.rb).
    def search_entities(entity, limit=10, min_relevance=0.0)
      
    end
    
  end
end