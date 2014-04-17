class EntityDate < ActiveRecord::Base

  include DC::Store::DocumentResource
  include DC::Store::EntityResource

  belongs_to :document
  belongs_to :account
  belongs_to :organization

  # Destroy and recreate all of a document's dates, from the text. Save the
  # document after running this method in order to save the dates.
  def self.reset(document)
    text = document.combined_page_text
    return false unless text
    document.entity_dates.destroy_all
    DC::Import::DateExtractor.new.extract_dates(text).each do |hash|
      model = self.new(:document => document, :date => hash[:date], :occurrences => Occurrence.to_csv(hash[:occurrences]))
      document.entity_dates << model
    end
  end

  # NB: We use "to_f.to_i" because "to_i" isn't defined for DateTime objects
  # that fall outside a distance of 30 bits from the regular UNIX Epoch.
  def as_json(options={})
    data = {
      'id'           => id,
      'document_id'  => document_id,
      'date'         => date.to_time.to_f.to_i
    }
    data['excerpts'] = excerpts(150, self.pages.limit(200) ) if options[:include_excerpts]
    data
  end

end
