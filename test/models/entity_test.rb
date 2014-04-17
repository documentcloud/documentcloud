require 'test_helper'

class EntityTest < ActiveSupport::TestCase


  let (:person) { entities(:person) }

  it "has associations and they query successfully" do
    assert_associations_queryable person
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
    assert_equal 1, Entity.search_in_documents('person', person.value, Document.ids ).count
  end

  it "can merge together" do
    duplicate = person.dup
    duplicate.occurrences = '57:2,53:1'
    duplicate.relevance = 0.5
    person.merge( duplicate )
    assert_equal 0.75, person.relevance
#    assert_equal "206057:16,223728:6,57:2,53:1", person.occurrences
  end

  it "extracts pages from occurrences" do
    assert person.textual?
    assert person.pages.include? pages(:first)
  end

  it "stores value" do
    person.value = ('a name of a person that is very long, at least longer than 255 characters for sure.' * 10 )
    assert_equal 255, person.value.length
  end

  it "generates custom json" do
    data = ActiveSupport::JSON.decode person.to_json(:include_excerpts=>true)
    assert data['excerpts']
  end

  it "has canonical" do
    data = person.canonical
    %w{ kind value relevance }.each{ |k|
      assert_equal person.send(k), data.delete(k)
    }
    assert_empty data
  end

end
