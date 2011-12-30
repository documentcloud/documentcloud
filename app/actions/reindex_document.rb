require File.dirname(__FILE__) + '/support/setup'

class ReindexDocument < CloudCrowd::Action

  def process
    puts "Reindexing Document: #{document.title}"
    document.reindex_all! access
    true
  end


  private

  def document
    return @document if @document
    ActiveRecord::Base.establish_connection
    @document = Document.find(input)
  end

  def access
    options['access'] || document.access
  end

end