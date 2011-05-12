require File.dirname(__FILE__) + '/support/setup'

class ReprocessEntities < CloudCrowd::Action

  def process
    puts "Reprocessing Entities: #{document.title}"
    DC::Import::EntityExtractor.new.extract document, document.combined_page_text
    true
  end


  private

  def document
    return @document if @document
    ActiveRecord::Base.establish_connection
    @document = Document.find(input)
  end

end