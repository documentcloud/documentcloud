require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  
  context "The search parser" do
    
    should "parse full text searches as phrases" do
      query = search("I'm a full text phrase")
      assert query.is_a? DC::Search::Query
      assert !query.has_fields?
      assert query.has_text?
      assert query.text == "I'm a full text phrase"
    end
    
  end
  
end