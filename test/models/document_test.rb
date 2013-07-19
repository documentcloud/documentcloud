require 'test_helper'

class DocumentTest < ActiveSupport::TestCase

  subject { documents(:tv_manual) }

  it "has associations and they query successfully" do
    assert_associations_queryable doc
  end

  it "has scopes that are queryable" do
    assert_working_relations( Document, [
        :chronological,:random,:published,:unpublished,:pending,
        :failed,:unrestricted, :restricted,:finished,:popular,:due
      ] )
    assert Document.owned_by( louis )
    assert Document.since( Date.parse( '2013-01-01' ) )
  end


  it "restricts access to appropriate accounts" do
    assert Document.accessible( accounts(:freelancer_bob), nil ).include?( doc )
    refute Document.accessible( accounts(:freelancer_bob), nil ).include?( documents(:top_secret) )
    assert Document.accessible( louis, organizations(:tribune) ).include?( documents(:top_secret) )
  end

  it "can be searched using database" do
    assert Document.search( "document:#{doc.id}" ).results.include?( doc )
    assert Document.search( "account:#{louis.id}" ).results.include?( doc )
    refute Document.search( "account:#{louis.id}" ).results.include?( documents(:top_secret) )
  end

  it "can be searched using solr" do
    search = Document.search( "super keywords" )
    assert_is_search_for Sunspot.session, Document
    assert_has_search_params Sunspot.session.searches.last, :keywords, 'super keywords'
  end

  it "publishes documents once due" do
    doc.update_attributes :access=>Document::PRIVATE, :publish_at=>(Time.now-1.day)
    assert Document.due.where( :id=>doc.id ).any?
    Document.publish_due_documents
    doc.reload
    assert doc.public?
  end

  it "sets annotation counts" do
    assert_equal 2, doc.annotations.count
    Document.populate_annotation_counts( louis, [doc] )
    assert_equal 2, doc.annotation_count

    assert_equal 102, doc.public_note_count # from fixture, is wildly inaccurate
    doc.reset_public_note_count
    assert_equal 1, doc.public_note_count # much better
  end

  it "strips whitespace from title" do
    title = "a good document, but poorly titled"
    document = Document.new
    document.title= " #{title}   "
    assert_equal title, document.title
  end

  it "combines text from pages" do
    assert_equal 'Call me Ishmael.This is the glorious second page', doc.combined_page_text
  end

  it "calculates annotations per page" do
    assert_equal 2, doc.per_page_annotation_counts
  end

  it "calculates ordered sections" do
    assert_equal [], doc.ordered_sections
  end

  it "calculates ordered annotations" do
    assert_equal [annotations(:private),annotations(:public)], doc.ordered_annotations( louis )
  end

  it "populates author information on annotations" do
    notes = doc.annotations_with_authors( louis )
    assert_equal annotations(:private), notes.first
    assert_equal notes.first.author[:full_name], louis.full_name
  end

  it "provides entity values" do
    assert doc.entities.none?
    assert doc.entities.create! :kind=>'person', :value=>'king kong'
    assert_equal ['king kong'], doc.entity_values('person')
  end

  it "collects entities as a hash" do
    assert doc.entities.create! :kind=>'person', :value=>'king kong'
    assert_equal [{:value=>'king kong',:relevance=>0.0}], doc.ordered_entity_hash['person']
  end

  it "calculates number of characters" do
    assert_equal 146055,doc.char_count # from fixture, is wildly inaccurate
    doc.reset_char_count!
    doc.reload
    assert_equal 33, doc.char_count
  end

  it "has boolean helper checks" do
    assert doc.titled?
    doc.title = Document::DEFAULT_TITLE
    refute doc.titled?
    assert doc.public?
    assert doc.publicly_accessible?

    refute doc.published?
    doc.remote_url = 'http://example.com/my_precious'
    assert doc.published?

    doc.access = Document::EXCLUSIVE
    refute doc.public?
    assert doc.publicly_accessible?
    doc.access = Document::PRIVATE
    refute doc.publicly_accessible?

    refute doc.commentable?( accounts(:freelancer_bob) )
    assert doc.commentable?( louis ) # he's the owner
    doc.access = Document::POSTMODERATED
    assert doc.commentable?( louis )
    assert doc.commentable?( accounts(:freelancer_bob) )
    assert doc.publicly_accessible?

  end

  it "clears published at when marking public" do
    ts = documents(:top_secret)
    ts.publish_at = Time.now+2.days
    ts.set_access( Document::PUBLIC )
    assert_nil ts.publish_at
  end

  it "propagates ownership changes to associations" do
    doc.set_owner( joe )
    assert_equal doc.account_id, joe.id
    assert_empty doc.pages.where([ 'account_id<>?',joe ])
    assert_empty doc.entities.where([ 'account_id<>?',joe ])
    assert_empty doc.entity_dates.where([ 'account_id<>?',joe ])
  end

  it "delegates methods" do
    assert_equal doc.organization.name, doc.organization_name
    assert_equal doc.account.full_name, doc.account_name
  end

  it "stores and retrieves docdata" do
    assert_empty doc.data
    doc.data = 'one=>1'
    assert_equal( { 'one'=>'1' } , doc.reload.data )
    doc.data = {:one=>1,:foo=>'bar',:answer=>42}
    # n.b. - all keys/values are converted to strings
    assert_equal( {"foo"=>"bar", "one"=>"1", "answer"=>"42"}, doc.reload.data )
  end

  it "encodes paths and urls" do
    base = "documents/#{doc.id}"
    assert_equal base, doc.path
    slug = "#{doc.path}/#{doc.slug}"
    assert_equal "#{slug}.pdf", doc.original_file_path
    assert_equal "#{slug}.txt", doc.full_text_path
    assert_equal "#{slug}.pdf", doc.pdf_path
    assert_equal "#{slug}.rdf", doc.rdf_path
    assert_equal "#{base}/pages", doc.pages_path
    assert_equal "#{base}/annotations", doc.annotations_path
    assert_equal "#{doc.id}-#{doc.slug}", doc.canonical_id
    assert_equal "#{base}-#{doc.slug}.json", doc.canonical_path
    assert_equal "/#{base}-#{doc.slug}.js", doc.canonical_cache_path
    assert_equal "#{doc.slug}-p{page}-{size}.gif", doc.page_image_template
    assert_equal "#{doc.slug}-p{page}.txt", doc.page_text_template
    assert_equal "#{DC::Store::AssetStore.web_root}/#{slug}.pdf", doc.public_pdf_url
    assert_equal "#{DC.server_root}/#{slug}.pdf", doc.private_pdf_url
    assert_equal doc.public_pdf_url, doc.pdf_url
    assert_equal secret_doc.private_pdf_url, secret_doc.pdf_url
    assert_equal "#{DC::Store::AssetStore.web_root}/#{base}/pages/#{doc.slug}-p1-thumbnail.gif", doc.thumbnail_url

    assert_equal "#{DC::Store::AssetStore.web_root}/#{slug}.txt", doc.public_full_text_url
    assert_equal "#{DC.server_root}/#{slug}.txt", doc.private_full_text_url
    assert_equal doc.public_full_text_url, doc.full_text_url
    assert_equal secret_doc.private_full_text_url, secret_doc.full_text_url

    assert_equal "#{DC.server_root}/#{base}-#{doc.slug}.html",doc.document_viewer_url
  end

  it "retrives project ids" do
    # document#project_ids used to be an explicit method that contained:
    #    self.project_memberships.map {|m| m.project_id }
    # it was removed in favor of the more efficient Rail's _ids auto-method
    assert_equal [195501225], doc.project_ids
  end

  it "submits jobs" do
    doc.reprocess_entities
    assert_job_action 'reprocess_entities'
  end


end
