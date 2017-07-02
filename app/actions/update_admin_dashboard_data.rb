require File.dirname(__FILE__) + '/support/setup'

class UpdateAdminDashboardData < CloudCrowd::Action

  def process
    begin
      @data = {
        stats: {
          documents_by_access:           DC::Statistics.documents_by_access,
          embedded_documents:            DC::Statistics.embedded_document_count,
          average_page_count:            DC::Statistics.average_page_count,
          daily_documents:               keys_to_timestamps(DC::Statistics.daily_documents(1.month.ago)),
          daily_pages:                   keys_to_timestamps(DC::Statistics.daily_pages(1.month.ago)),
          weekly_documents:              keys_to_timestamps(DC::Statistics.weekly_documents),
          weekly_pages:                  keys_to_timestamps(DC::Statistics.weekly_pages),
          daily_hits_on_documents:       keys_to_timestamps(DC::Statistics.daily_hits_on_documents(1.month.ago)),
          weekly_hits_on_documents:      keys_to_timestamps(DC::Statistics.weekly_hits_on_documents),
          daily_hits_on_notes:           keys_to_timestamps(DC::Statistics.daily_hits_on_notes(1.month.ago)),
          weekly_hits_on_notes:          keys_to_timestamps(DC::Statistics.weekly_hits_on_notes),
          daily_hits_on_searches:        keys_to_timestamps(DC::Statistics.daily_hits_on_searches(1.month.ago)),
          weekly_hits_on_searches:       keys_to_timestamps(DC::Statistics.weekly_hits_on_searches),
          total_pages:                   DC::Statistics.total_pages,

          instances:                     [],
          remote_url_hits_last_week:     DC::Statistics.remote_url_hits_last_week,
          remote_url_hits_all_time:      DC::Statistics.remote_url_hits_all_time,
          count_organizations_embedding: DC::Statistics.count_organizations_embedding,
          count_total_collaborators:     DC::Statistics.count_total_collaborators,
          numbers:                       DC::Statistics.by_the_numbers,
        },
        updated_at:       Time.now,
        documents:        Document.finished.chronological.limit(5).map {|d| d.admin_attributes },
        failed_documents: Document.failed.chronological.limit(3).map {|d| d.admin_attributes },
        top_documents:    RemoteUrl.top_documents(7, 5),
        top_searches:     RemoteUrl.top_searches(7,  5),
        top_notes:        RemoteUrl.top_notes(7, 5),
        accounts:         [],
      }
      
      asset_store = DC::Store::AssetStore.new
      asset_store.cache_json(@data, "admin/index.json")
      
    rescue Exception => e
      LifecycleMailer.exception_notification(e,options).deliver_now
      raise e
    end
    true
  end
  
  def keys_to_timestamps(hash)
    result  = {}
    strings = hash.keys.first.is_a? String
    hash.each do |key, value|
      time = (strings ? Date.parse(key) : key ).to_time
      utc  = (time + time.utc_offset).utc
      result[utc.to_f.to_i] = value
    end
    result
  end

end
