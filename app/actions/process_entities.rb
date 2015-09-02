require File.join(File.dirname(__FILE__), 'support', 'document_action')

class ProcessEntities < DocumentAction
  def process
    puts "Reprocessing Entities: #{document.title}"
    EntityDate.reset(document)
    DC::Import::EntityExtractor.new.extract document, document.combined_page_text
    true
  end
end