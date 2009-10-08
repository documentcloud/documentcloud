require 'test_helper'

class SearchParserTest < ActiveSupport::TestCase
  
  def search(phrase)
    @parser.parse(phrase)
  end
  
  context "The search parser" do
    setup { @parser = DC::Search::Parser.new }
    
    should "parse full text searches as phrases" do
      query = search("I'm a full text phrase")
      assert query.is_a? DC::Search::Query
      assert !query.fielded?
      assert query.textual?
      assert query.phrase == "I'm a full text phrase"
    end
    
    should "parse fielded searches into fields" do
      query = search("country: england country:russia organization: 'A B C D'")
      assert !query.textual?
      assert !query.compound?
      assert query.fielded?
      assert query.fields.first.type == 'country'
      assert query.fields.first.value == 'england'
      assert query.fields.last.type == 'organization'
      assert query.fields.last.value == 'A B C D'
    end
    
    should "be able to handle compound searches" do
      query = search("category: food bacon lettuce tomato country:jamaica")
      assert query.compound? && query.fielded? && query.textual?
      assert query.phrase == "bacon lettuce tomato"
      assert query.fields.first.type == 'category'
      assert query.fields.last.value == 'jamaica'
      assert query.fields.first.value == 'food'
    end
    
    should "transform boolean ORs into Sphinx-compatible ones" do
      query = search("person:peter mike   OR   tom")
      assert query.compound? && query.fielded? && query.textual?
      assert query.phrase == "mike | tom"
    end
    
    should "pull out title and source fielded searches" do
      query = search("title:launch freedom rides source:times title:duty")
      assert query.title == 'launch | duty'
      assert query.source == 'times'
      assert query.phrase == 'freedom rides'
    end
    
  end
  
end