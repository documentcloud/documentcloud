require 'test_helper'
require 'dc/import/entity_extractor'

class EntityExtractorTest < ActiveSupport::TestCase

  test "Can extract document with rdf attached" do
    document = Document.new(title: "My secret story")
    text = "One million years ago, there was not a lot of internet."
    extractor = DC::Import::EntityExtractor.new.extract(document, text)
    byebug
    assert extractor.entities.present?
  end
end
