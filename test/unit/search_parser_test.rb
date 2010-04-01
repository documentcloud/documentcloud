require 'test_helper'

class SearchParserTest < ActiveSupport::TestCase

  def search(text)
    @parser.parse(text)
  end

  context "The search parser" do
    setup { @parser = DC::Search::Parser.new }

    should "parse full text searches as phrases" do
      query = search("I'm a full text phrase")
      assert query.is_a? DC::Search::Query
      assert !query.has_fields?
      assert query.has_text?
      assert query.text == "I'm a full text phrase"
    end

    should "parse fielded searches into fields" do
      query = search("country: england country:russia glump: 'A B C D'")
      assert !query.has_text?
      assert query.has_fields?
      assert query.fields.first.kind == 'country'
      assert query.fields.first.value == 'england'
      assert query.fields.last.kind == 'glump'
      assert query.fields.last.value == 'A B C D'
    end

    should "be able to handle compound searches" do
      query = search("category: food bacon lettuce tomato country:jamaica")
      assert query.has_fields? && query.has_text?
      assert query.text == "bacon lettuce tomato"
      assert query.fields.first.kind == 'category'
      assert query.fields.last.value == 'jamaica'
      assert query.fields.first.value == 'food'
    end

    should "transform boolean ORs into Sphinx-compatible ones" do
      query = search("person:peter mike   OR   tom")
      assert query.has_fields? && query.has_text?
      assert query.text == "mike | tom"
    end

    should "pull out title and source fielded searches" do
      query = search("title:launch freedom rides source:times title:duty")
      assert query.attributes[0].value == 'launch'
      assert query.attributes[0].kind  == 'title'
      assert query.attributes[1].value == 'times'
      assert query.attributes[1].kind  == 'source'
      assert query.attributes[2].value == 'duty'
      assert query.attributes[2].kind  == 'title'
      assert query.text == 'freedom rides'
    end

    should "be able to handle fields with quotes in the values" do
      query = search("project: \"2052: Berkeley's Olympics\"")
      assert query.projects[0] == "2052: Berkeley's Olympics"
    end

  end

end