class Instance
  
  attr_reader :offset, :length
  
  # When instances are stored in the database, they are serialized into CSV
  # of the form: offset:length (ex. 13:5,103:5,376:5).
  def self.to_csv(instances)
    instances.map {|i| "#{i.offset}:#{i.length}"}.join(',')
  end
  
  # Parse serialized instances back out into objects from a CSV string.
  def self.from_csv(csv)
    csv.split(',').map {|pair| Instance.new(*pair.split(':').map{|n| n.to_i }) }
  end
  
  def initialize(offset, length)
    @offset, @length = offset, length
  end
  
end