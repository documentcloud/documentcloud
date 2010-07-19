module DC

  module CSV

    def self.generate_csv(records, keys=nil)
      keys ||= records.first.keys

      csv_string = FasterCSV.generate do |csv|
        csv << keys
        records.each do |record|
          record_array = []
          keys.each {|key| record_array.push record[key] }
          csv << record_array
        end
      end

      return csv_string
    end

  end

end