require File.dirname(__FILE__) + '/support/setup'

class IndexDocuments < CloudCrowd::Action
  
  def process
    Document.where(id: input).each{ |doc| DC::Search.repository.save(doc) }
    true
  end
end

__END__
counter = 0
Document.pluck(:id).each_slice(5000) do |ids|
  counter+=1
  RestClient.post(DC::CONFIG['cloud_crowd_server'] + '/jobs', {:job => { 
    :action => 'elastic_index', 
    :inputs => [ids]
  }.to_json})
  puts counter
end; ''
