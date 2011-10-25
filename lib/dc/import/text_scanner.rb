require 'strscan'

module DC
  module Import

    # A character-aware replacement for **StringScanner**, which correctly
    # provides offsets and lengths in characters for matches on UTF text.
    class TextScanner

      # Initialize the **TextScanner** with a string of text.
      def initialize(text)
        @text     = text
        @scanner  = StringScanner.new(@text)
      end

      # Matches a given **regex** to all of its occurrences within the **text**,
      # yielding to the block with the matched text, the character offset
      # and character length of the match.
      def scan(regex)
        last_byte, last_char = 0, 0
        while @scanner.scan_until(regex)
          match   = @scanner.matched
          byte    = @scanner.pos - match.length
          char    = last_char + @text[last_byte..byte].unpack('U*').length - 1
          length  = match.unpack('U*').length
          last_byte, last_char = byte, char
          yield match, char, length
        end
      end

    end

  end
end