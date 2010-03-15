module DC
  module Import

    # Extracts phone numbers from raw text. For now, we support the
    # [North American Numbering Plan](http://en.wikipedia.org/wiki/North_American_Numbering_Plan),
    # in the following formats:
    #
    #     800-555-1212
    #     800 555 1212
    #     800.555.1212
    #     (800) 555-1212
    #     1-800-555-1212
    #     800-555-1212-1234
    #     800-555-1212x1234
    #     work 1-(800) 555.1212 #1234
    #
    class PhoneExtractor

      # List of cached Regexes we use to do the dirty extraction work.
      SEP = "[.\\/\\-\\s]"
      PHONE_MATCHER = /\(?(\d{3}?)\)?#{SEP}?(\d{3})#{SEP}(\d{4})(#{SEP}?(x|#)?(\d*))?/

      # Extracts the unique phone numbers within the text.
      def extract_phone_numbers(text)
        @numbers = {}
        scanner = TextScanner.new(text)
        scanner.scan(PHONE_MATCHER) do |match, offset, length|
          next unless number = to_phone_number(match)
          @numbers[number] ||= {:number => number, :occurrences => []}
          @numbers[number][:occurrences].push(Occurrence.new(offset, length))
        end
        @numbers.values
      end


      private

      # Converts the any-format number into the canonical (xxx) xxx-xxxx format.
      def to_phone_number(number)
        string, area, trunk, rest, a, b, ext = *number.match(PHONE_MATCHER)
        number = "(#{area}) #{trunk}-#{rest}"
        number += " x#{ext}" unless ext.blank?
        number
      end

    end

  end
end
