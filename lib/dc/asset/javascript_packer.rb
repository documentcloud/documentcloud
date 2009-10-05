module DC
  module Asset
    
    # Compresses Javascript by removing whitespace and comments.
    class JavascriptPacker
      
      IDENTIFIER  = /[\w\\$]/
      PUNCTUATION = /[(,=:\[!&|?{};\n]/

      def reset(source)
        @source  = source.unpack('U*')
        @current = "\n"
        @next    = ''
        @result  = ''
      end
      
      # Get the next character. Watch out for lookahead. If the character is a
      # control character, translate it into a space or newline.
      def get
        return nil if @source.empty?
        c = @source.shift.chr
        c >= ' ' || c == "\n" ? c : c == "\r" ? "\n" : ' '
      end
      
      # Get the next character without consuming it.
      def peek
        @source.empty? ? nil : @source.first.chr
      end
      
      # Get the next character, excluding comments.
      # peek is used to see if a '/' if followed by another '/', or '*'.
      def next_character
        c = get
        return c unless c == '/' && (peek == '/' || peek == '*') 
        return consume_single_line_comment if peek == '/'
        consume_multi_line_comment
      end
      
      # Is the character a letter, digit, underscore, dollar, or non-ASCII?
      def alpha_numeric?(c)
        c && (c.match(IDENTIFIER) || c[0] > 126)
      end
      
      # Read ahead to the end of the '//' comment.
      def consume_single_line_comment
        loop do 
          c = get 
          return c if c <= "\n"
        end
      end
      
      # Read ahead to the end of the '/* */' comment.
      def consume_multi_line_comment
        get
        loop do
          case get
          when '*' then return get && ' ' if peek == '/'
          when nil then raise "Unterminated comment"
          end
        end
      end
      
      # Read in until the end of the contents of the current string.
      def consume_string
        loop do
          @result << @current
          @current = get
          break if @current == @next
          raise "Unterminated string literal" if @current <= "\n"
          if @current == "\\"
            @result << @current
            @current = get
          end
        end
      end
      
      # Read in until the end of the regular expression.
      def consume_regex
        @result << @current
        @result << @next
        loop do
          @current = get
          break if @current == '/'
          raise "Unterminated RegExp Literal" if @current <= "\n"
          @result << @current
        end
        @next = next_character
      end
      
      # Three alternatives here:
      #   * :output (output current, copy next to current, fetch next)
      #   * :copy   (copy next to current, fetch next)
      #   * :next   (just fetch next).
      def action(t)
        @result << @current if t == :output
        if t == :output || t == :copy
          @current = @next
          consume_string if @current == '"' || @current == "'"
        end
        @next = next_character
        consume_regex if @next == '/' && @current.match(PUNCTUATION)
      end
      
      # If the next char is alpha-numeric, then we output, otherwise just copy.
      def next_char_action
        action alpha_numeric?(@next) ? :output : :copy
      end
      
      # If the current char is alpha-numeric, then we output, otherwise skip.
      def current_char_action
        action alpha_numeric?(@current) ? :output : :next
      end
      
      # Compress the javascript in the source string, removing comments, and
      # uncessesary whitespace, replacing tabs with spaces, and carriage returns 
      # with linefeeds.
      def compress(source)
        reset source
        action :next
        while @current do
          case @current
          when ' ' then next_char_action
          when "\n"
            case @next
            when '{', '[', '(', '+', '-' then action :output
            when ' ' then action :next
            else next_char_action
            end
          else
            case @next
            when ' ' then current_char_action
            when "\n"
              case @current
              when '}', ']', ')', '+', '-', "\\", "'", '"' then action :output
              else current_char_action
              end
            else action :output
            end
          end
        end
        @result
      end
      
    end
    
  end
end