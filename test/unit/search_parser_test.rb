require 'test_helper'

class SearchParserTest < ActiveSupport::TestCase
  
  context "The search parser" do
    setup { @parser = DC::Search::Parser.new }
    
    should "parse full text searches as phrases" do
      query_string = "I'm a full text phrase"
      query = @parser.parse(query_string)
      assert query.is_a? DC::Search::Query
      assert !query.fielded?
      assert query.textual?
      assert query.phrase == query_string
    end
    
    should "parse fielded searches into fields" do
      query_string = "country: england country:russia organization: 'A B C D'"
      query = @parser.parse(query_string)
      assert !query.textual?
      assert !query.compound?
      assert query.fielded?
      assert query.fields.first.type == 'country'
      assert query.fields.first.value == 'england'
      assert query.fields.last.type == 'organization'
      assert query.fields.last.value == 'A B C D'
    end
    
    should "be able to handle compound searches" do
      query_string = "category: food bacon lettuce tomato country:jamaica"
      query = @parser.parse(query_string)
      assert query.compound? && query.fielded? && query.textual?
      assert query.phrase == "bacon lettuce tomato"
      assert query.fields.first.type == 'category'
      assert query.fields.last.value == 'jamaica'
      assert query.fields.first.value == 'food'
    end
    
    should "transform boolean ORs into Sphinx-compatible ones" do
      query_string = "person:peter mike   OR   tom"
      query = @parser.parse(query_string)
      assert query.compound? && query.fielded? && query.textual?
      assert query.phrase == "mike | tom"
    end
    
  end
  
end