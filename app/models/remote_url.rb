require 'cgi'

class RemoteUrl < ActiveRecord::Base
 
  self.establish_connection( DC::ANALYTICS_DB ) unless Rails.env.testing?
  belongs_to :document
  belongs_to :note, :class_name=>'Annotation'
  DOCUMENT_CLOUD_URL = /^https?:\/\/(www\.)?documentcloud.org/

  scope :aggregated, -> {
    select( 'sum(hits) AS hits, document_id, url' )
    .group( 'document_id, url' )
  }

 scope :by_document, -> {
    select( 'sum(hits) AS hits, document_id' )
    .group( 'document_id' )
    .having( 'document_id is not NULL' )
  }

  scope :by_search_query, -> {
    select('sum(hits) AS hits, search_query, url')
    .group( 'search_query, url' )
    .having( 'search_query is not NULL' )
  }

  scope :by_note, -> {
    select( 'sum(hits) AS hits, note_id, url' )
    .group( 'note_id, url' )
    .having( 'note_id is not NULL' )
  }

  def self.record_hits_on_document(doc_id, url, hits)
    url = url.mb_chars[0...255].to_s
    row = self.find_or_create_by(:document_id=>doc_id, :url=>url, :date_recorded=>Time.now.utc.to_date)
    row.update_attributes :hits => row.hits + hits

    # Increment the document's total hits.
    doc = Document.find_by_id(doc_id)
    doc.update_attributes(:hit_count => doc.hit_count + hits) if doc
  end

  def self.record_hits_on_page(doc_id, page_number, url, hits)
    url = url.mb_chars[0...255].to_s
    row = self.find_or_create_by(:document_id=>doc_id, :page_number=>page_number, :url=>url, :date_recorded=>Time.now.utc.to_date)
    row.update_attributes :hits => row.hits + hits

    # Increment the document's total hits.
    doc = Document.find_by_id(doc_id)
    doc.update_attributes(:hit_count => doc.hit_count + hits) if doc
  end

  def self.record_hits_on_search(query, url, hits)
    url   = url[0...255]
    query = CGI::unescape(query)
    row   = self.find_or_create_by( :search_query=>query, :url=>url, :date_recorded=>Time.now.utc.to_date )
    row.update_attributes :hits => row.hits + hits
  end

  def self.record_hits_on_note(note_id, url, hits)
    url = url.mb_chars[0...255].to_s
    row = self.find_or_create_by( :note_id=>note_id, :url=>url, :date_recorded=>Time.now.utc.to_date )
    row.update_attributes :hits => row.hits + hits
  end

  # Using the recorded remote URL hits, correctly set detected remote urls
  # for all listed document ids. This method is only ever run within a
  # background job.
  def self.populate_detected_document_ids(doc_ids)
    urls = self.aggregated.where({:document_id => doc_ids})
    top  = urls.inject({}) do |memo, url|
      if DOCUMENT_CLOUD_URL =~ url.url
        memo
      else
        id = url.document_id
        memo[id] = url if !memo[id] || memo[id].hits < url.hits
        memo
      end
    end
    Document.where(:id=>top.keys).find_in_batches do | documents |
      documents.each do | doc |
        doc.detected_remote_url = top[doc.id].url
        doc.save if doc.changed?
      end
    end
  end

  def self.top_documents( days=7, limit=1000 )
    hit_documents = self.top_query( days, limit ).by_document
    docs = Document.find( hit_documents.map(&:document_id) ).inject({}) do |memo, doc|
      memo[doc.id] = doc
      memo
    end
    hit_documents.select {|url| !!docs[url.document_id] }.map do |url|
      url_attrs = url.attributes
      url_attrs[:url] = docs[url.document_id].published_url
      url_attrs[:id] = "#{url.document_id}:#{url_attrs[:url]}"
      first_hit = RemoteUrl.where( :document_id => url['document_id'] ).order('created_at ASC').first.created_at
      url_attrs[:first_recorded_date] = first_hit.strftime "%a %b %d, %Y"
      docs[url.document_id].admin_attributes.merge(url_attrs)
    end
  end

  def self.top_searches( days=7, limit=1000 )
    hit_searches = self.top_query( days, limit ).by_search_query
    hit_searches.map do |query|
      query_attrs = query.attributes
      first_hit = RemoteUrl.where( :search_query => query.search_query ).order('created_at ASC').first.created_at
      query_attrs[:first_recorded_date] = first_hit.strftime "%a %b %d, %Y"
      query_attrs
    end
  end

  def self.top_notes(days=7, limit=1000 )
    hit_notes = self.top_query( days, limit ).by_note
    notes = Annotation.find( hit_notes.map(&:note_id) ).inject({}) do |memo, note|
      memo[note.id] = note.canonical.merge({:document_id => note.document_id})
      memo
    end
    docs = Document.find( notes.map {|id, n| n[:document_id] } ).inject({}) do |memo, doc|
      memo[doc.id] = doc
      memo
    end
    hit_notes.select {|note| !!notes[note.note_id] }.map do |note|
      note_attrs = note.attributes
      note_attrs.delete :id
      note_attrs[:document] = docs[notes[note.note_id][:document_id]]
      first_hit = RemoteUrl.where( {:note_id => note.note_id} ).order('created_at ASC').first.created_at
      note_attrs[:first_recorded_date] = first_hit.strftime "%a %b %d, %Y"
      notes[note.note_id].merge(note_attrs)
    end

  end

  private

  def self.top_query( days, limit )
    self
      .where(['date_recorded > ?', days.days.ago] )
      .having( 'sum(hits) > 0' )
      .order(  'sum(hits) desc' )
      .limit(limit)
  end

end
