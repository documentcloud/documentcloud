module DC

  module CSV

    def self.generate_csv(records, keys=nil)
      keys ||= records.first.keys

      FasterCSV.generate do |csv|
        csv << keys
        records.each do |record|
          csv << keys.map {|key| record[key] }
        end
      end
    end

  end

end