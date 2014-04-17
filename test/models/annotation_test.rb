require 'test_helper'

class AnnotationTest < ActiveSupport::TestCase


  it "has associations and they query successfully" do
    assert_associations_queryable doc
  end

  it "has scopes that are queryable" do
    assert_working_relations( Annotation, [ :unrestricted ] )

  end

  it "restricts access to appropriate accounts" do
    assert Annotation.accessible( accounts(:freelancer_bob) ).include?( annotations(:public) )
    refute Annotation.accessible( accounts(:freelancer_bob) ).include?( annotations(:private) )
    assert Annotation.accessible( louis ).include?( annotations(:private) )
  end

  it "returns document counts" do
    assert_equal 2, Annotation.counts_for_documents( louis, [doc] )[ doc.id ]
  end

  it "populates author info" do
    Annotation.populate_author_info(Annotation.all).each do | note |
      assert_equal note.author[:full_name], note.account.full_name
    end
  end

  it "counts public notes by organization" do
    assert_equal 1, Annotation.public_note_counts_by_organization[ tribune.id ]
  end

  it "finds it's page" do
    assert_equal 2, annotations(:public).page_number
    assert_equal 2, annotations(:public).page.page_number
  end

  it "returns canonical info" do
    note = annotations(:public)
    Annotation.populate_author_info( [ note] )
    json = note.canonical( :include_image_url=>true, :include_document_url=>true )
    assert json['image_url']
    assert json['published_url']
    assert_equal note.title, json['title']
    assert_equal louis.full_name, json['author']
  end

  it "makes sure it has a title" do
    note = annotations(:public)
    note.title = ''
    assert note.save
    assert_equal "Untitled Annotation", note.title
  end

  it "includes extra data with to_json" do
    json = ActiveSupport::JSON.decode annotations(:public).to_json
    assert_equal annotations(:public).document.id, json['document_id']
  end

end
