module DC
  module Import
    
    class SphinxXMLPipe
      
      def xml
        text_paths = DC::Store::AssetStore.new.full_text_paths
        
        xml = Nokogiri::XML::Document.new
        xml.encoding = 'utf-8'
        docset = Nokogiri::XML::Node.new('sphinx:docset', xml)
        schema = Nokogiri::XML::Node.new('sphinx:schema', xml)
        field  = Nokogiri::XML::Node.new('sphinx:field', xml)
        field['name'] = 'full_text'
        exists = Nokogiri::XML::Node.new('sphinx:attr', xml)
        exists['name'] = 'exists'
        exists['type'] = 'bool'
        
        docset << schema
        schema << field
        schema << exists
        xml << docset
        
        text_paths.each do |path|
          id = File.basename(path, '.txt')
          doc = Nokogiri::XML::Node.new('sphinx:document', xml)
          doc['id'] = Document.integer_id(id).to_s
          full_text = Nokogiri::XML::Node.new('full_text', xml)
          full_text.content = File.read(path).gsub(/[^[:print:]]/, '')
          existence = Nokogiri::XML::Node.new('exists', xml)
          existence.content = '1'
          
          # Alternate approaches that don't work...
          # to_xs is way, way too slow for production -- especially if 
          # we're rebuilding the index all the time. At least parallelize it 
          # in CloudCrowd.
          # full_text.content = File.read(path).to_xs
          # full_text << Nokogiri::XML::CDATA.new(xml, File.read(path).to_xs)
          # full_text.content = `iconv -f UTF-8 -t UTF-8 #{path}`
          # full_text.content = File.read(path).unpack('C*').pack('U*')
          # full_text.content = converter.iconv(File.read(path) << ' ')[0..-2]
          
          doc << full_text
          doc << existence
          docset << doc
        end
        
        xml.to_xml(:indent => 2)
      end
      
    end
    
  end
end