class MetadataDate < ActiveRecord::Base

  include DC::Store::DocumentResource

  belongs_to :document

  # Destroy and recreate all of a document's dates, from the text. Save the
  # document after running this method in order to save the dates.
  def self.refresh(document)
    return false unless document.text
    document.metadata_dates.destroy_all
    DC::Import::DateExtractor.new.extract_dates(document.text).each do |hash|
      model = self.new(:document => document, :date => hash[:date], :occurrences => Occurrence.to_csv(hash[:occurrences]))
      document.metadata_dates << model
    end
  end

  # Instead of having a separate table for occurrences, we serialize them to
  # a CSV format on each Metadatum. Deserializes.
  def split_occurrences
    Occurrence.from_csv(self.occurrences)
  end

  # NB: We use "to_f.to_i" because "to_i" isn't defined for DateTime objects
  # that fall outside a distance of 30 bits from the regular UNIX Epoch.
  def to_json(options=nil)
    {'document_id'  => document_id,
     'date'         => date.to_time.to_f.to_i }.to_json
  end

end