require 'test_helper'

class MetadataExtractorTest < ActiveSupport::TestCase

  RDF = File.read("#{Rails.root}/test/fixtures/honeybee_article.rdf")

  def initialize(*args)
    super(*args)
    @doc = Document.create(:organization_id => 1, :account_id => 1, :access => DC::Access::PUBLIC)
    DC::Import::MetadataExtractor.new.extract_metadata(@doc, :rdf => RDF)
  end

  context "The Calais Extractor" do

    setup { @doc.save }

    should "be able to extract the standard metadata" do
      assert @doc.title             == "World agricultural honeybee disappearance"
      assert @doc.language          == 'en'
      assert @doc.publication_date  == Date.parse('Wed, 21 Mar 2007')
      assert @doc.calais_id == '1897e340-2365-4b63-9c18-40af7df14648'
    end

    should "be able to extract the Calais-identified entities" do
      assert @doc.metadata.length == 28
      assert @doc.metadata.map(&:kind).uniq.sort ==
        %w(city country organization person place state technology term)

      meta = @doc.metadata[-2]
      assert meta.value     == "Pennsylvania Department of Agriculture"
      assert meta.kind      == "organization"
      assert meta.calais_id == '48ccaeea-e553-3ef8-905c-32bc4bfb627f'
      assert meta.relevance == 0.312

      occurrence = meta.split_occurrences.first
      assert occurrence.offset == 518
      assert occurrence.length == 38
    end

  end

end