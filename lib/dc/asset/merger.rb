module DC
  module Asset
    
    # Knows how, given a list of directory globs, to compile a unique, ordered
    # list of the desired files, compress and concatenate them into a single
    # download.
    class Merger
      
      CSS_GLOBS = ASSET_CONFIG[:stylesheets]
      JS_GLOBS  = ASSET_CONFIG[:javascripts]
                
      CSS_PATHS = CSS_GLOBS.map {|glob| Dir[glob] }.flatten!.uniq!
      JS_PATHS  = JS_GLOBS.map {|glob| Dir[glob] }.flatten!.uniq!
                
      CSS_URLS  = CSS_PATHS.map {|p| p.sub(/\Apublic/, DC_CONFIG['server_root']) }
      JS_URLS   = JS_PATHS.map {|p| p.sub(/\Apublic/, DC_CONFIG['server_root']) }
      
      def compile_css
        compile(CSS_PATHS, CSSPacker)
      end
      
      def compile_js
        compile(JS_PATHS, JavascriptPacker)
      end
      
      def compile(paths, packer_class)
        packer  = packer_class.new
        paths.map {|path| packer.compress(File.read(path)) }.join("\n")
      end
      
    end
    
  end
end
