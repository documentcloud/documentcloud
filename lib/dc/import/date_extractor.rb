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

      DIGITS  = "(\\d{1,4})"
      MONTHS  = "(jan(uary)?|feb(ruary)?mar(ch)?|apr(il)?|may|jun(e)?|jul(y)?|aug(ust)?|sep(tember)?|oct(ober)?|nov(ember)?|dec(ember)?)\.?"
      SEP     = "[.\\/-]"

      DATE_MATCHERS = [
        /#{DIGITS}#{SEP}#{DIGITS}#{SEP}#{DIGITS}/,
        /#{MONTHS}\s+#{DIGITS},?\s+#{DIGITS}/i,
        /#{DIGITS}\s+#{MONTHS},?\s+#{DIGITS}/i
      ]

      def extract_dates(text)
        @dates = []
        @scanner = StringScanner.new(text)
        DATE_MATCHERS.each {|matcher| scan_for(matcher) }
        @dates
      end


      private

      def scan_for(matcher)
        @scanner.reset
        while @scanner.scan_until(matcher)
          date = to_date(@scanner.matched)
          @dates << date if date
        end
      end

      def to_date(string)
        date =   string.gsub(/#{SEP}/, '/').to_time.to_date rescue nil
        date ||= string.gsub(/#{SEP}/, '-').to_time.to_date rescue nil
        date
      end

    end

  end
end
