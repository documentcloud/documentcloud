require 'test_helper'

class EntityTest < ActiveSupport::TestCase


  it "has associations and they query successfully" do
    assert_associations_queryable entities(:person)
  end

  it "has scopes that are queryable" do
    assert_equal 1, Entity.kind(:person).count
  end

  it "can determine if it's present in a document" do
    meta = Entity.new(:kind => 'person', :value => 'Seal', :occurrences => '101:4')
    assert meta.textual?
  end

  it "can access occurrences as objects" do
    meta = Entity.new(:kind => 'person', :value => 'Seal', :occurrences => '50:4,101:4') 
    occurrences = meta.split_occurrences
    assert occurrences.all? {|o| o.is_a? Occurrence }
    assert occurrences.last.offset == 101
    assert occurrences.last.length == 4
  end

  it "normalizes titles" do
    # Possible BUG?  Shouldn't normalize_value do this?
    # assert_equal 'A Test String', Entity.normalize_value( 'a test string')
    assert_equal 'FEDEX', Entity.normalize_value('FEDEX')
  end

  it "searches in documents" do
    assert_equal 1, Entity.search_in_documents('person', entities(:person).value, Document.ids ).count
  end

end
