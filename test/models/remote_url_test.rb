require 'test_helper'

class RemoteUrlTest < ActiveSupport::TestCase

  it "has scopes that are queryable" do
    assert_working_relations( RemoteUrl, [ :aggregated, :by_document, :by_search_query, :by_note ] )
  end

  it "records document hits" do
    assert_difference 'RemoteUrl.count', 1 do
      RemoteUrl.record_hits_on_document( doc.id, 'foo', 1 )
      RemoteUrl.record_hits_on_document( doc.id, 'foo', 3 )
    end
  end

  it "records search hits" do
    qs = 'account:%205676-nathan-stitt%20date:%20"2011-11'
    assert_difference 'RemoteUrl.count', 1 do
      RemoteUrl.record_hits_on_search( qs, 'foo', 8 )
      RemoteUrl.record_hits_on_search( qs, 'foo', 3 )
    end
  end


  it "records hits on notes" do
    note = annotations(:public)
    assert_difference 'RemoteUrl.count', 1 do
      RemoteUrl.record_hits_on_note( note.id, 'foo', 23)
      RemoteUrl.record_hits_on_note( note.id, 'foo', 2)
    end
  end

  it "populates detected document ids" do
    assert_nil secret_doc.detected_remote_url
    RemoteUrl.record_hits_on_document( secret_doc.id, 'http://gogole.com/', 1 )
    RemoteUrl.populate_detected_document_ids( [ secret_doc.id ] )
    secret_doc.reload
    assert_equal 'http://gogole.com/',secret_doc.detected_remote_url
  end

  it "calculates top_documents" do
    (1..10).each do | index |
      RemoteUrl.record_hits_on_document( secret_doc.id, 'http://test.com/#{index}', index - 1 )
      RemoteUrl.record_hits_on_document( doc.id, 'http://test.com/#{index}', index )
    end
    docs = RemoteUrl.top_documents
    assert_equal 73, docs.first['hits']
    assert_equal 45, docs.last['hits']
  end

  it "calculates top searches" do
    qs = 'account:%205676-nathan-stitt%20date:%20"2011-11'
    RemoteUrl.record_hits_on_search( qs, 'foo', 3 )
    searches = RemoteUrl.top_searches
    assert_equal 13, searches.first['hits']
  end

  it "calculate note searches" do
    note = annotations(:public)
    RemoteUrl.record_hits_on_note( note.id, 'foo', 23)
    notes = RemoteUrl.top_notes
    assert_equal 23, notes.first['hits']
  end

end
