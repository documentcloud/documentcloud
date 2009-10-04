module DC
  module Asset
    
    # Compresses CSS by removing whitespace and comments.
    class CSSPacker
      
      # Pilfered from Scott Becker's Asset Packager.
      def compress(source)
        source.gsub!(/\s+/, " ")           # collapse whitespace
        source.gsub!(/\/\*(.*?)\*\//, "")  # remove comments - caution, might want to remove this if using css hacks
        source.gsub!(/\} /, "}\n")         # add line breaks
        source.gsub!(/\n$/, "")            # remove last break
        source.gsub!(/ \{ /, " {")         # trim inside brackets
        source.gsub!(/; \}/, "}")          # trim inside brackets
      end
      
    end
    
  end
end