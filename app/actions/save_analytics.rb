require File.dirname(__FILE__) + '/support/setup'

class SaveAnalytics < CloudCrowd::Action

  def process
    handle_errors do
      hits = input.keys.inject({}) do |memo, hit|
        type, key = *hit.split(':', 2)
        unless ['document', 'search', 'page', 'note'].include? type
          type = 'document'
          key  = hit
        end
        memo[type] ||= {}
        memo[type][key] = input[hit]
        memo
      end
      hits.each_pair do |type, type_hits|
        case type
        when 'document' then self.record_document_hits type_hits
        when 'search'   then self.record_search_embed_hits type_hits
        when 'page'     then self.record_page_hits type_hits
        when 'note'     then self.record_note_hits type_hits
        end
      end
    end
  end
  
  def record_document_hits(hits)
    doc_ids = []
    hits.each_pair do |key, type_hits|
      id, url = *key.split(':', 2)
      id = id.to_i
      next unless url && Document.unrestricted.exists?(id)
      doc_ids << id
      RemoteUrl.record_hits_on_document(id, url, type_hits)
    end
    RemoteUrl.populate_detected_document_ids(doc_ids)
  end
  
  def record_page_hits(hits)
    doc_ids = []
    hits.each_pair do |key, type_hits|
      doc_page_combo, url = *key.split(':', 2)
      doc_id, page_number = doc_page_combo.split('p', 2)
      doc_id      = doc_id.to_i
      page_number = page_number.to_i
      next unless url && Document.unrestricted.exists?(doc_id)
      doc_ids << doc_id
      RemoteUrl.record_hits_on_page(doc_id, page_number, url, type_hits)
    end
    RemoteUrl.populate_detected_document_ids(doc_ids)
  end
  
  def record_search_embed_hits(hits)
    hits.each_pair do |key, type_hits|
      query, url = *key.split(':', 2)
      next unless url
      RemoteUrl.record_hits_on_search(query, url, type_hits)
    end
  end
  
  def record_note_hits(hits)
    hits.each_pair do |key, type_hits|
      id, url = *key.split(':', 2)
      id = id.to_i
      next unless url && Annotation.unrestricted.exists?(id)
      RemoteUrl.record_hits_on_note(id, url, type_hits)
    end
  end


  private

  def handle_errors
    begin
      yield
    rescue Exception => e
      LifecycleMailer.exception_notification(e,options).deliver_now
      raise e
    end
    true
  end

end
