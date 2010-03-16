# An instance of an entity occurring at a given position in a document.
class Occurrence

  attr_reader :offset, :length, :entity

  # When occurrences are stored in the database, they are serialized into CSV
  # of the form: offset:length (ex. 13:5,103:5,376:5).
  def self.to_csv(ocurrences)
    ocurrences.map {|i| "#{i.offset}:#{i.length}"}.join(',')
  end

  # Parse serialized occurrences back out into objects from a CSV string.
  def self.from_csv(csv, entity=nil)
    csv.split(',').map do |pair|
      Occurrence.new(*[pair.split(':').map{|n| n.to_i }, entity].flatten)
    end
  end

  def initialize(offset, length, entity=nil)
    @offset, @length, @entity = offset, length, entity
  end

  # Return this occurrence's offset relative to its page.
  def page_offset
    offset - page.start_offset
  end

  def page
    @page ||= @entity.pages([self]).first
  end

end