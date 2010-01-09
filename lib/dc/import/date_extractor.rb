require 'strscan'

module DC
  module Import

    # Supported formats:
    #
    # 10/13/2009  (10-13-2009)
    # 10/13/09    (10-13-09)
    # 2009/10/13  (2009-10-13)
    #
    # 13 October 2009 (13 Oct 2009)
    # October 13 2009 (Oct 13 2009)
    class DateExtractor

      # List of cached Regexes we use to do the dirty date extraction work.

      DIGITS  = "(\\d{1,4})"
      MONTHS  = "(jan(uary)?|feb(ruary)?mar(ch)?|apr(il)?|may|jun(e)?|jul(y)?|aug(ust)?|sep(tember)?|oct(ober)?|nov(ember)?|dec(ember)?)\.?"
      SEP     = "[.\\/-]"

      DATE_MATCHERS = [
        /#{DIGITS}#{SEP}#{DIGITS}#{SEP}#{DIGITS}/,
        /#{MONTHS}\s+#{DIGITS},?\s+#{DIGITS}/i,
        /#{DIGITS}\s+#{MONTHS},?\s+#{DIGITS}/i
      ]

      SEP_REGEX = /#{SEP}/
      SPLITTER  = /#{SEP}|,?\s+/m
      NUMERIC   = /\A\d+\Z/

      # Extracts only the unique dates within the text. Duplicate dates are
      # ignored.
      def extract_dates(text)
        @dates = {}
        @scanner = StringScanner.new(text)
        DATE_MATCHERS.each {|matcher| scan_for(matcher) }
        @dates.keys
      end


      private

      def scan_for(matcher)
        @scanner.reset
        while @scanner.scan_until(matcher)
          date = to_date(@scanner.matched)
          @dates[date] = true if date
        end
      end

      # Is a string a valid 4-digit year?
      def valid_year?(str)
        str.match(NUMERIC) && str.length == 4
      end

      # ActiveRecord's to_time only supports two-digit years up to 2038.
      # (because the UNIX epoch overflows 30 bits at that point, probably).
      # For now, let's ignore dates without centuries.
      def to_date(string)
        list =   string.split(SPLITTER)
        return   nil unless valid_year?(list.first) || valid_year?(list.last)
        date =   string.gsub(SEP_REGEX, '/').to_time.to_date rescue nil
        date ||= string.gsub(SEP_REGEX, '-').to_time.to_date rescue nil
        return   nil if date && date.year >= 2038
        date
      end

    end

  end
end
