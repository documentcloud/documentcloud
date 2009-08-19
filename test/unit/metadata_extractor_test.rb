require 'test_helper'

class MetadataExtractorTest < ActiveSupport::TestCase
  
  RDF = File.read(File.dirname(__FILE__) + "/honeybee_article.rdf")
  
  def initialize(*args)
    super(*args)
    @calais = DC::Import::MetadataExtractor.new
    @doc = Document.new(:rdf => RDF)
    @calais.extract_metadata(@doc)
  end
  
  context "The Calais Extractor" do
    
    should "be able to extract the standard metadata" do
      assert @doc.title             == "World agricultural honeybee disappearance"
      assert @doc.language          == 'English'
      assert @doc.date              == Date.parse('Wed, 21 Mar 2007')
      assert @doc.calais_signature  == "digestalg-1|qC1AZ/AeTEkvL4aLoWeI8dv9oRA=|Fs1iG3hFHGPjsQcjeFCLdNV5Sp4KZWdGFUV4WaU8122G7emcGHFqkw=="
      assert @doc.calais_request_id == '1897e340-2365-4b63-9c18-40af7df14648'
    end
    
    should "be able to extract the document's categories" do
      assert @doc.categories.count == 1
      category = @doc.categories.first
      assert category.value == 'other'
      assert !category.textual?
      assert category.document_id == @doc.id
    end
    
    # Although we really shouldn't be asking Calais for the full text, 
    # it's handy for loading the WikiNews Calais RDF corpus for testing.
    should "be able to extract the document's full text" do
      assert @doc.full_text
      assert @doc.full_text[0...30] == "At least 24 states across the "
      assert @doc.summary == @doc.full_text[0...255]
    end
    
    should "be able to extract the Calais-identified entities" do
      assert @doc.metadata.length == 33
      assert @doc.metadata.map(&:type).uniq.sort ==
        %w(category city country facility industry_term natural_feature 
           organization person position province_or_state region technology)
           
      meta = @doc.metadata[-2]
      assert meta.value       == "Pennsylvania Department of Agriculture"
      assert meta.type        == "organization"
      assert meta.calais_hash == '48ccaeea-e553-3ef8-905c-32bc4bfb627f'
      assert meta.relevance   == 0.312
      
      occurrence = meta.occurrences.first
      assert occurrence.offset == 518
      assert occurrence.length == 38
    end
    
  end
  
end