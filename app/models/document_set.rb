class DocumentSet
  
  attr_accessor :documents, :metadata
  
  def initialize(documents=[])
    @documents = documents
    @metadata = []
  end
  
  def populate_metadata
    @documents.each {|doc| @metadata += doc.metadata }
  end
  
  def as_json(opts={})
    {
      'documents' => @documents,
      'metadata' => @metadata
    }
  end
  
end