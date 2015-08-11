require 'csv'

module DC

  module CSV

    def self.generate_csv(records, keys=nil)
      return if records.none?
      keys ||= records.first.keys
      ::CSV.generate do |csv|
        csv << keys
        records.each do |record|
          csv << keys.map {|key| record[key] }
        end
      end
    end

  end

end
