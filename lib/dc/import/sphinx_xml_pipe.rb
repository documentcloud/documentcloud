module DC
  module Import
    
    class SphinxXMLPipe
      include Nokogiri::XML
      
      def xml        
        @xml = Nokogiri::XML::Document.new
        @xml.encoding = 'utf-8'
        @docset = node('sphinx:docset')
        
        @docset << schema_definition
        full_text_documents.each {|doc_node| @docset << doc_node }
        
        @xml << @docset
        @xml.to_xml(:indent => 2)
      end
      
      # XML Representations of all the documents with full text.
      def full_text_documents
        entry_store = DC::Store::EntryStore.new
        doc_ids = entry_store.open_for_reading {|store| store.keys }
        doc_ids.map do |doc_id|
          entry = entry_store.find(doc_id)
          doc = node('sphinx:document', 'id' => entry.integer_id.to_s)
          full_text = node('full_text')
          full_text.content = entry.full_text.gsub(/[^[:print:]]/, '')
          organization_id = node('organization_id')
          organization_id.content = entry.organization_id
          account_id = node('account_id')
          account_id.content = entry.account_id
          access = node('access')
          access.content = entry.access
          doc << full_text
          doc << organization_id
          doc << account_id
          doc << access
          doc
        end
      end
      
      # See SCHEMA.txt for a clearer picture.
      def schema_definition
        schema = node('sphinx:schema')
        field  = node('sphinx:field', 'name' => 'full_text')
        organization_id = node('sphinx:attr', 'name' => 'organization_id', 'type' => 'int', 'bits' => '32')
        account_id = node('sphinx:attr', 'name' => 'account_id', 'type' => 'int', 'bits' => '32')
        access = node('sphinx:attr', 'name' => 'access', 'type' => 'int', 'bits' => '8')
        
        schema << field
        schema << organization_id
        schema << account_id
        schema << access
        schema
      end
      
      def node(type, attributes=nil)
        node = Node.new(type, @xml)
        attributes.each {|name, value| node[name] = value } if attributes
        node
      end
      
    end
    
  end
end

# Alternate approaches that don't work...
# to_xs is way, way too slow for production -- especially if 
# we're rebuilding the index all the time. At least parallelize it 
# in CloudCrowd.
# full_text.content = File.read(path).to_xs
# full_text << Nokogiri::XML::CDATA.new(xml, File.read(path).to_xs)
# full_text.content = `iconv -f UTF-8 -t UTF-8 #{path}`
# full_text.content = File.read(path).unpack('C*').pack('U*')
# full_text.content = converter.iconv(File.read(path) << ' ')[0..-2]
