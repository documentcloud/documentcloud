require 'date'

module DC
  module Import

    # Supported formats:
    #
    # 10/13/2009  (10-13-2009)
    # 10/13/2019    (10-13-2019)
    # 2009/10/13  (2009-10-13)
    #
    # 13 October 2009 (13 Oct 2009)
    # October 13 2009 (Oct 13 2009)
    class DateExtractor

      # List of cached Regexes we use to do the dirty date extraction work.

      DIGITS      = "(\\b\\d{1,4}\\b)"
      MONTHS      = "(jan(uary)?|feb(ruary)?mar(ch)?|apr(il)?|may|jun(e)?|jul(y)?|aug(ust)?|sep(tember)?|oct(ober)?|nov(ember)?|dec(ember)?)\.?"
      SEP         = "[.\\/\\-]"

      NUM_MATCH   = "#{DIGITS}#{SEP}#{DIGITS}#{SEP}#{DIGITS}"
      MDY_MATCH   = "#{MONTHS}\\s*#{DIGITS},?\\s+#{DIGITS}"
      YMD_MATCH   = "#{DIGITS}\\s*#{MONTHS},?\\s*#{DIGITS}"

      DATE_MATCH  = /(#{NUM_MATCH}|#{MDY_MATCH}|#{YMD_MATCH})/i

      SEP_REGEX   = /#{SEP}/
      SPLITTER    = /#{SEP}|,?\s+/m
      NUMERIC     = /\A\d+\Z/

      AMERICAN_REGEX = /(\d{1,2})#{SEP}(\d{1,2})#{SEP}(\d{4})/

      # Extract the unique dates within the text.
      def extract_dates( text )
        @dates = {}
        scan_for(DATE_MATCH, text)
        reject_outliers
        @dates.values
      end

      def self.american
        DC::Import::DateExtractor.new( true )
      end

      def self.international
        DC::Import::DateExtractor.new( false )
      end

      def initialize( american_format = true )
        @american_format = american_format
      end


      private

      # Scans for the regex within the text, saving valid dates and occurrences.
      def scan_for(matcher, text)
        scanner = TextScanner.new(text)
        scanner.scan(matcher) do |match, offset, length|
          next unless date = to_date(match)
          @dates[date] ||= {:date => date, :occurrences => []}
          @dates[date][:occurrences].push(Occurrence.new(offset, length))
        end
      end

      # Ignoring dates that are outside of three standard deviations ...
      # they're probably errors.
      def reject_outliers
        dates     = @dates.values.map {|d| d[:date] }
        count     = dates.length
        return true if count < 10 # Not enough dates for detection.
        nums      = dates.map {|d| d.to_time.to_f.to_i }
        mean      = nums.inject {|a, b| a + b } / count.to_f
        deviation = Math.sqrt(nums.inject(0){|sum, n| sum + (n - mean) ** 2 } / count.to_f)
        allowed   = ((mean - 3.0 * deviation)..(mean + 3.0 * deviation))
        @dates.delete_if {|date, hash| !allowed.include?(date.to_time.to_f) }
      end

      # Is a string a valid 4-digit year?
      def valid_year?(str)
        str.match(NUMERIC) && str.length == 4
      end

      # ActiveRecord's to_time only supports two-digit years up to 2038.
      # (because the UNIX epoch overflows 30 bits at that point, probably).
      # For now, let's ignore dates without centuries,
      # and dates that are too far into the past or future.
      def to_date(string)
        list = string.split(SPLITTER)
        return nil unless valid_year?(list.first) || valid_year?(list.last)
        if @american_format # US format dates need to have month and day swapped for Date.parse
          string.sub!( AMERICAN_REGEX ){|m| "#$3-#$1-#$2"}
        end
        date =   Date.parse(string.gsub(SEP_REGEX, '/'), true) rescue nil
        date ||= Date.parse(string.gsub(SEP_REGEX, '-'), true) rescue nil
        return   nil if date && (date.year <= 0 || date.year >= 2100)
        date
      end

    end

  end
end
