require File.dirname(__FILE__) + '/support/setup'

class SaveAnalytics < CloudCrowd::Action

  def process
    handle_errors do
      hits = input.keys.inject({}) do |memo, hit|
        type, key = *hit.split(':', 2)
        unless ['document', 'search', 'note'].include? type
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
      next unless url && (doc = Document.unrestricted.find_by_id(id))
      doc_ids << id
      RemoteUrl.record_hits_on_document(id, url, type_hits)
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
      next unless url && (note = Annotation.unrestricted.find_by_id(id))
      RemoteUrl.record_hits_on_note(id, url, type_hits)
    end
  end


  private

  def handle_errors
    begin
      yield
    rescue Exception => e
      LifecycleMailer.deliver_exception_notification(e)
      raise e
    end
    true
  end

end