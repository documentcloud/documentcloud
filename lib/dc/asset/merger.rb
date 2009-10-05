module DC
  module Asset
    
    # Knows how, given a list of directory globs, to compile a unique, ordered
    # list of the desired files, compress and concatenate them into a single
    # download.
    class Merger
      
      def compile_css(globs)
        compile(globs, CSSPacker)
      end
      
      def compile_js(globs)
        compile(globs, JavascriptPacker)
      end
      
      def compile(globs, packer_class)
        paths   = determine_file_list(globs)
        packer  = packer_class.new
        paths.map {|path| packer.compress(File.read(path)) }.join("\n")
      end
      
      # Expand all globs in order, then remove duplicate entries.
      def determine_file_list(globs)
        globs.map {|glob| Dir[glob] }.flatten!.uniq!
      end
      
    end
    
  end
end