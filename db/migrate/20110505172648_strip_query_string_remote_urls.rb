class StripQueryStringRemoteUrls < ActiveRecord::Migration
  
  def self.up
    RemoteUrl.find_each do |url|
      if url.url.include? '?'
        new_url, query_string = *url.url.split('?', 2)
        url.update_attributes :url => new_url
        
        all_urls = RemoteUrl.all(:conditions => {
          :date_recorded  => url.date_recorded, 
          :url            => new_url,
          :document_id    => url.document_id,
          :note_id        => url.note_id,
          :search_query   => url.search_query,
        }, :order => 'created_at asc')
        if all_urls.count > 1
          total_hits = all_urls.inject(0) {|memo, hit| memo += hit.hits }
          all_urls[1, all_urls.length].each do |u| 
            puts " ---> Destroying: #{u.url} - #{u.hits} hits"
            u.destroy
          end
          puts " ---> Not Destroying: #{all_urls[0].url} - #{all_urls[0].hits}"
          all_urls[0].hits = total_hits
          all_urls[0].save
          puts " ---> Saving: #{new_url} - #{total_hits} hits"
        end
      end
    end
  end

  def self.down
  end
end
