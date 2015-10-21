require 'test_helper'
require 'dc/import/entity_extractor'

class EntityExtractorTest < ActiveSupport::TestCase

  def setup
    @text = "Fair use is a limitation and exception to the exclusive right granted by copyright law to the author of a creative work. In United States copyright law, fair use is a doctrine that permits limited use of copyrighted material without acquiring permission from the rights holders."
  end

  test "Pull out standard top level entities and add to document" do
    document = FactoryGirl.create(:document, title: "Wow look at the title", language: nil, publication_date: nil, calais_id: nil)
    mock_calais_object = OpenStruct.new(raw: OpenStruct.new(body: OpenStruct.new(doc: OpenStruct.new(info: OpenStruct.new(docId: '1', docTitle: "Awesome doc title", docDate: Time.now, calaisRequestID: "123456789")))))
    # Invoke private method to test
    DC::Import::EntityExtractor.new.send(:extract_information, document, mock_calais_object)
    assert document.title && document.language && document.publication_date && document.calais_id 
  end

  test "Can extract entities & positions that Calais discovers" do
    VCR.use_cassette "open_calais/info_extraction" do
      document = FactoryGirl.create(:document)
      chunks = DC::Import::CalaisFetcher.new.fetch_rdf(@text)
      entities = DC::Import::EntityExtractor.new.send(:extract_entities, document, chunks[0], 0)
      assert entities
    end
  end

  test "Can extract document with rdf attached" do
    VCR.use_cassette "open_calais/rdf_extract" do
      document = FactoryGirl.create(:document)
      extract_entities = DC::Import::EntityExtractor.new.extract(document, @text)
      assert extract_entities.present?
    end
  end
end
