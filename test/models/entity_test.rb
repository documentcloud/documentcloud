require 'test_helper'

class EntityTest < ActiveSupport::TestCase

  context "An Entity" do

    should_belong_to :document

    should "be able to determine if it's present in a document" do
      meta = Entity.new(:kind => 'person', :value => 'Seal', :occurrences => '101:4')
      assert meta.textual?
    end

    should "be able to access occurrences as objects" do
      meta = Entity.new(:kind => 'person', :value => 'Seal', :occurrences => '50:4,101:4')
      occurrences = meta.split_occurrences
      assert occurrences.all? {|o| o.is_a? Occurrence }
      assert occurrences.last.offset == 101
      assert occurrences.last.length == 4
    end

  end

end