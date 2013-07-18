require 'test_helper'


class DocumentTest < ActiveSupport::TestCase

  subject { documents(:tv_manual) }
  let (:tv_manual) { documents(:tv_manual) }

  it "has associations and they query successfully" do
    assert_associations_queryable tv_manual
  end

  it "has scopes that are queryable" do
    assert_working_relations( Document, [
        :chronological,:random,:published,:unpublished,:pending,
        :failed,:unrestricted, :restricted,:finished,:popular,:due
      ] )
    assert Document.owned_by( accounts(:louis) )
    assert Document.since( Date.parse( '2013-01-01' ) )
  end


  it "restricts access to appropriate accounts" do
    assert Document.accessible( accounts(:freelancer_bob), nil ).include?( tv_manual )
    refute Document.accessible( accounts(:freelancer_bob), nil ).include?( documents(:top_secret) )
    assert Document.accessible( accounts(:louis), organizations(:tribune) ).include?( documents(:top_secret) )
  end

  it "can be searched using database" do
    assert Document.search( "document:#{tv_manual.id}" ).results.include?( tv_manual )
    assert Document.search( "account:#{accounts(:louis).id}" ).results.include?( tv_manual )
    refute Document.search( "account:#{accounts(:louis).id}" ).results.include?( documents(:top_secret) )
  end

  it "can be searched using solr" do
    search = Document.search( "super keywords" )
    assert_is_search_for Sunspot.session, Document
    assert_has_search_params Sunspot.session.searches.last, :keywords, 'super keywords'
  end

  it "publishes documents once due" do
    tv_manual.update_attributes :access=>Document::PRIVATE, :publish_at=>(Time.now-1.day)
    assert Document.due.where( :id=>tv_manual.id ).any?
    Document.publish_due_documents
    tv_manual.reload
    assert tv_manual.public?
  end

  it "sets annotation counts" do
    assert_equal 2, tv_manual.annotations.count
    Document.populate_annotation_counts( accounts(:louis), [tv_manual] )
    assert_equal 2, tv_manual.annotation_count
  end

  it "strips whitespace from title" do
    title = "a good document, but poorly titled"
    document = Document.new
    document.title= " #{title}   "
    assert_equal title, document.title
  end

  it "combines text from pages" do
    assert_equal 'Call me Ishmael.This is the glorious second page', tv_manual.combined_page_text
  end

  it "calculates annotations per page" do
    assert_equal 2, tv_manual.per_page_annotation_counts
  end

  it "calculates ordered sections" do
    assert_equal [], tv_manual.ordered_sections
  end

  it "calculates ordered annotations" do
    assert_equal [annotations(:private),annotations(:public)], tv_manual.ordered_annotations( accounts(:louis) )
  end


end
