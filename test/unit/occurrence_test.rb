require 'test_helper'

class OccurrencesTest < ActiveSupport::TestCase
    
  context "Occurrences of metadata in a document" do
            
    should "be able to serialize and deserialize" do
      serialized = "1:2,3:4,5:6"
      occurrences = Occurrence.from_csv(serialized)
      assert Occurrence.to_csv(occurrences) == serialized
      assert occurrences.first.offset == 1
      assert occurrences.first.length == 2
      assert occurrences.last.offset == 5
      assert occurrences.last.length == 6
    end
    
  end
  
end