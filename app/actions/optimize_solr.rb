require File.dirname(__FILE__) + '/support/setup'

class OptimizeSolr < CloudCrowd::Action

  def process
    RestClient.get Sunspot.config.solr.url + '/update?optimize=true&waitFlush=false'
    true
  end

end