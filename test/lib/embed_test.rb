require_relative '../test_helper'
require 'pry'

describe DC::Embed::Document do
  
  let(:resource) do
    doc_url = doc.canonical_url(:html)
    Struct.new(:id, :resource_url, :type).new(doc.id, doc_url, :document)
  end
  let(:config_data) do
    {
      :sidebar           => false,
      :pdf               => true,
      :maxwidth          => 400,
      :maxheight         => 500,
      :responsive_offset => 12,
      :container         => ".hi"
    }
  end
  
  it "should require a resource" do
    Proc.new{ DC::Embed::Document.new(nil, {}) }.must_raise ArgumentError
    Proc.new{ DC::Embed::Document.new({}, {})  }.must_raise ArgumentError

    DC::Embed::Document.new(resource, {}).must_be_kind_of DC::Embed::Document
  end
  
  it "should output HTML markup for iframe based embedding" do
    embed_code = Nokogiri::HTML(DC::Embed::Document.new(resource, {}).code)
    iframe = embed_code.css("iframe")
    iframe.wont_be_empty
    iframe = iframe.first
    
    iframe.attribute("src").value.must_match doc.iframe_embed_src_url
  end

  it "should output HTML for JS based embedding" do
    skip # until embed dom mechanism is configurable
    embed_code = Nokogiri::HTML(DC::Embed::Document.new(resource, {}).code)
    embed_code.css("#DV-viewer-#{resource.id}").wont_be_empty
    
    # Embed code should include two script tags 
    external_scripts = embed_code.xpath("//script[@src]")
    external_scripts.count.must_equal 1
    external_scripts.first.attribute("src").value.must_match /loader.js$/

    code_scripts     = embed_code.xpath("//script[not(@src)]")
    code_scripts.count.must_equal 1
  end

  it "should output an oembed response for a JS Embed as json" do
    skip # until embed dom mechanism is configurable
    oembed_data = DC::Embed::Document.new(resource, {:sidebar=>false}, {:strategy=>:oembed}).as_json
    html = Nokogiri::HTML(oembed_data[:html])
    
    code_scripts = html.xpath("//script[not(@src)]")
    code_scripts.count.must_equal 2
    
    viewer_code = html.xpath("//script[@src]")
    viewer_code.count.must_equal 1
    viewer_code.first.attribute("src").value.must_match /viewer.js$/
  end
  
  it "should output a JST template"

  it "should configure embed code based on config settings" do
    config = {
      :sidebar => false
    }
    embed = DC::Embed::Document.new(resource, config)
    embed.embed_config[:sidebar].must_equal false
    embed.code.must_match /sidebar/
  end
  
  it "should convert string values to their literal values" do
    string_config_values = Hash[config_data.map{ |k,v| [k, v.to_s] }]
    embed = DC::Embed::Document.new(resource, string_config_values)
    
    config = embed.embed_config
    config_data.keys.each do |key|
      config[key].must_equal config_data[key]
    end
  end
  
  it "should output to keys the viewer recognizes"

end
