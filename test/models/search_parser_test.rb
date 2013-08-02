require 'test_helper'

class SearchParserTest < ActiveSupport::TestCase

  def search(text)
    @parser.parse(text)
  end

  setup { @parser = DC::Search::Parser.new }

  it "parses full text searches as phrases" do
    query = search("I'm a full text phrase")
    assert query.is_a? DC::Search::Query
    assert !query.has_fields?
    assert query.has_text?
    assert query.text == "I'm a full text phrase"
  end

  it "parses fielded searches into fields" do
    query = search("country: england country:russia")
    assert !query.has_text?
    assert query.has_fields?
    assert query.fields.first.kind == 'country'
    assert query.fields.first.value == 'england'
  end

  it "is able to handle compound searches" do
    query = search("state: wyoming bacon lettuce tomato country:jamaica")
    assert query.has_fields? && query.has_text?
    assert query.text == "bacon lettuce tomato"
    assert query.fields.first.kind == 'state'
    assert query.fields.last.value == 'jamaica'
    assert query.fields.first.value == 'wyoming'
  end

  it "transforms boolean ORs into Sphinx-compatible ones" do
    query = search("person:peter mike     OR   tom")
    assert query.has_fields? && query.has_text?
    assert_equal "mike OR tom", query.text
  end

  it "pulls out title and source fielded searches" do
    query = search("title:launch freedom rides source:times title:duty")
    assert query.attributes[0].value == 'launch'
    assert query.attributes[0].kind  == 'title'
    assert query.attributes[1].value == 'times'
    assert query.attributes[1].kind  == 'source'
    assert query.attributes[2].value == 'duty'
    assert query.attributes[2].kind  == 'title'
    assert query.text == 'freedom rides'
  end

  it "is able to handle fields with quotes in the values" do
    query = search("project: \"2052: Berkeley's Olympics\"")
    assert query.projects[0] == "2052: Berkeley's Olympics"
  end


end
