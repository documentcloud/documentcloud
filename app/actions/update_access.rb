require File.dirname(__FILE__) + '/support/setup'

class UpdateAccess < CloudCrowd::Action

  def process
    ActiveRecord::Base.establish_connection
    document = Document.find(input)
    DC::Store::AssetStore.new.set_access(document, document.access)
  end

end