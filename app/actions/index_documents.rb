require File.dirname(__FILE__) + '/support/setup'

class IndexDocuments < CloudCrowd::Action
  
  def process
    Document.where(id: input).each{ |doc| DC::Search.repository(doc.class).save(doc) }
    true
  end
end

__END__
def index_documents(limit=10000)
  counter = 0
  Document.limit(limit).pluck(:id).each_slice(5000) do |ids|
    counter+=1
    RestClient.post(DC::SECRETS['central_server'] + '/jobs', {:job => { 
      :action => 'index_documents', 
      :inputs => [ids]
    }.to_json})
    puts counter
  end; ''
end
