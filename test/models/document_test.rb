require 'test_helper'

class DocumentTest < ActiveSupport::TestCase

  subject { documents(:tv_manual) }

  def test_it_has_associations_and_they_query_successfully
    assert_associations_queryable doc
  end

  def test_has_scopes_that_are_queryable
    assert_working_relations( Document, [
        :chronological,:random,:published,:unpublished,:pending,
        :failed,:unrestricted, :restricted,:finished,:popular,:due
      ] )
    assert Document.owned_by( louis )
    assert Document.since( Date.parse( '2013-01-01' ) )
  end


  def test_restricts_access_to_appropriate_accounts
    assert Document.accessible( accounts(:freelancer_bob), nil ).include?( doc )
    refute Document.accessible( accounts(:freelancer_bob), nil ).include?( documents(:top_secret) )
    assert Document.accessible( louis, organizations(:tribune) ).include?( documents(:top_secret) )
  end

  def test_searched_using_database
    assert Document.search( "document:#{doc.id}" ).results.include?( doc )
    assert Document.search( "account:#{louis.id}" ).results.include?( doc )
    refute Document.search( "account:#{louis.id}" ).results.include?( documents(:top_secret) )
  end

  def test_searched_using_solr
    search = Document.search( "super keywords" )
    assert search.instance_variable_get(:@needs_solr)
  end

  def test_can_import_document
    doc = Document.upload({
        :url=>'http://test.com/file.pdf',
        :title=>"Test Doc",
        :make_public=>false,
        :email_me=>false
        }, louis, tribune )
    refute doc.new_record?
    assert_job_action 'document_import'
  end

  def test_document_viewer_url
    assert_equal "http://dev.dcloud.org/documents/368941146-tv.html", doc.document_viewer_url
    assert_equal "http://dev.dcloud.org/documents/368941146-tv.html#document/p2", doc.document_viewer_url(:page=>2)
    assert_equal "http://dev.dcloud.org/documents/368941146-tv.html#entity/p2/Mr%20Rogers/2:16",
                 doc.document_viewer_url(:page=>2,:entity=>doc.entities.first,:offset=>2)
  end

  def test_publishes_documents_once_due
    doc.update_attributes :access=>Document::PRIVATE, :publish_at=>(Time.now-1.day)
    assert Document.due.where( :id=>doc.id ).any?
    Document.publish_due_documents
    doc.reload
    assert doc.public?
  end

  def test_sets_annotation_counts
    assert_equal 2, doc.annotations.count
    Document.populate_annotation_counts( louis, [doc] )
    assert_equal 2, doc.annotation_count

    assert_equal 102, doc.public_note_count # from fixture, is wildly inaccurate
    doc.reset_public_note_count
    assert_equal 1, doc.public_note_count # much better
  end

  def test_strips_whitespace_from_title
    title = "a good document, but poorly titled"
    document = Document.new
    document.title= " #{title}   "
    assert_equal title, document.title
  end

  def test_combines_text_from_pages
    text = doc.pages.map(&:text).join('')
    assert_equal text, doc.combined_page_text
  end

  def test_calculates_annotations_per_page
    assert_equal( { 2=>1, 1=>1 }, doc.per_page_annotation_counts )
  end

  def test_calculates_ordered_sections
    assert_equal [sections(:first)], doc.ordered_sections
  end

  def test_calculates_ordered_annotations
    assert_equal [annotations(:private),annotations(:public)], doc.ordered_annotations( louis )
  end

  def test_populates_author_information_on_annotations
    notes = doc.annotations_with_authors( louis )
    assert_equal annotations(:private), notes.first
    assert_equal notes.first.author[:full_name], louis.full_name
  end

  def test_provides_entity_values
    assert doc.entities.create! :kind=>'person', :value=>'king kong'
    assert_equal [ 'Mr Rogers','king kong'], doc.entity_values('person').sort
  end

  def test_collects_entities_as_a_hash
    assert_equal [ { :value=>"Mr Rogers", :relevance=>1.0} ], doc.ordered_entity_hash['person']
  end

  def test_calculates_number_of_characters
    assert_equal 146055,doc.char_count # from fixture, is wildly inaccurate
    doc.reset_char_count!
    doc.reload
    assert_equal 33, doc.char_count
  end

  def test_has_working_boolean_helpers
    assert doc.titled?
    doc.title = Document::DEFAULT_TITLE
    refute doc.titled?
    assert doc.public?
    assert doc.publicly_accessible?

    assert doc.published?
    doc.remote_url = nil
    refute doc.published?

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

  def test_clears_published_at_when_marking_public
    ts = documents(:top_secret)
    ts.publish_at = Time.now+2.days
    ts.set_access( Document::PUBLIC )
    assert_nil ts.publish_at
  end

  def test_propagates_ownership_changes_to_associations
    doc.set_owner( joe )
    assert_equal doc.account_id, joe.id
    assert_empty doc.pages.where([ 'account_id<>?',joe ])
    assert_empty doc.entities.where([ 'account_id<>?',joe ])
    assert_empty doc.entity_dates.where([ 'account_id<>?',joe ])
  end

  def test_delegates_methods
    assert_equal doc.organization.name, doc.organization_name
    assert_equal doc.account.full_name, doc.account_name
  end

  def test_stores_and_retrieves_docdata
    assert_empty doc.data
    doc.data = 'one=>1'
    assert_equal( { 'one'=>'1' } , doc.reload.data )
    doc.data = {:one=>1,:foo=>'bar',:answer=>42}
    # n.b. - all keys/values are converted to strings
    assert_equal( {"foo"=>"bar", "one"=>"1", "answer"=>"42"}, doc.reload.data )
  end

  def test_it_cant_have_blank_data
    assert_empty doc.data
    doc.data = {}
    assert_nil doc.docdata
  end

  def test_it_deletes_on_blank
    doc.data = { one: 1 }
    refute_nil doc.docdata
    doc.data = {}
    assert doc.docdata.destroyed?, "Docdata wasn't destroyed when data was set to blank"
  end

  def test_encodes_paths_and_urls
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
    assert_equal "/#{base}-#{doc.slug}.json", doc.canonical_path
    assert_equal "/#{base}-#{doc.slug}.js", doc.canonical_js_cache_path
    assert_equal "/#{base}-#{doc.slug}.json", doc.canonical_json_cache_path
    assert_equal "#{doc.slug}-p{page}-{size}.gif", doc.page_image_template
    assert_equal "#{doc.slug}-p{page}.txt", doc.page_text_template
    assert_equal "#{DC.cdn_root(:force_ssl=>true)}/#{slug}.pdf", doc.public_pdf_url
    assert_equal "#{DC.server_root}/#{slug}.pdf", doc.private_pdf_url
    assert_equal doc.public_pdf_url, doc.pdf_url
    assert_equal secret_doc.private_pdf_url, secret_doc.pdf_url
    assert_equal "#{DC.cdn_root(:force_ssl=>true)}/#{base}/pages/#{doc.slug}-p1-thumbnail.gif", doc.thumbnail_url

    assert_equal "#{DC.cdn_root(:force_ssl=>true)}/#{slug}.txt", doc.public_full_text_url
    assert_equal "#{DC.server_root}/#{slug}.txt", doc.private_full_text_url
    assert_equal doc.public_full_text_url, doc.full_text_url
    assert_equal secret_doc.private_full_text_url, secret_doc.full_text_url

  end

  def test_retrives_project_ids
    # document#project_ids used to be an explicit method that contained:
    #    self.project_memberships.map {|m| m.project_id }
    # it was removed in favor of the more efficient Rail's _ids auto-method
    assert_equal [195501225], doc.project_ids
  end

  def test_submits_jobs
    doc.reprocess_entities
    assert_job_action 'reprocess_entities'
  end

  def test_job_recording
    assert_difference ->{ ProcessingJob.count }, 1 do
      doc.record_job '{ "id": "23" }'
    end
  end

end
