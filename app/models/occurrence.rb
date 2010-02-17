# An instance of an entity occurring at a given position in a document.
class Occurrence

  attr_reader :offset, :length, :metadatum

  # When occurrences are stored in the database, they are serialized into CSV
  # of the form: offset:length (ex. 13:5,103:5,376:5).
  def self.to_csv(ocurrences)
    ocurrences.map {|i| "#{i.offset}:#{i.length}"}.join(',')
  end

  # Parse serialized occurrences back out into objects from a CSV string.
  def self.from_csv(csv, metadatum=nil)
    csv.split(',').map do |pair|
      Occurrence.new(*[pair.split(':').map{|n| n.to_i }, metadatum].flatten)
    end
  end

  def initialize(offset, length, metadatum=nil)
    @offset, @length, @metadatum = offset, length, metadatum
  end

  # Return this occurrence's offset relative to its page.
  def page_offset
    offset - page.start_offset
  end

  def page
    @page ||= @metadatum.pages([self]).first
  end

end