require_relative '../test_helper'
require 'pry'

describe DC::Embed::Document do
  
  let(:resource) { Struct.new(:id, :url).new("1235", "https://lol.wat/1235") }
  
  it "should require a resource" do
    Proc.new{ DC::Embed::Document.new(nil, {}) }.must_raise ArgumentError
    Proc.new{ DC::Embed::Document.new({}, {})  }.must_raise ArgumentError

    DC::Embed::Document.new(resource, {}).must_be_kind_of DC::Embed::Document
  end
  
  it "should output HTML markup" do
    embed_code = Nokogiri::HTML(DC::Embed::Document.new(resource, {}).code)
    embed_code.css("#DV-viewer-#{resource.id}").wont_be_empty
    
    # Embed code should include two script tags 
    external_scripts = embed_code.xpath("//script[@src]")
    external_scripts.count.must_equal 1
    external_scripts.first.attribute("src").value.must_match /loader.js$/

    code_scripts     = embed_code.xpath("//script[not(@src)]")
    code_scripts.count.must_equal 1
  end

  it "should output an oembed response as json"
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
    input_config = {
      :sidebar           => false,
      :pdf               => true,
      :maxwidth          => 400,
      :maxheight         => 500,
      :responsive_offset => 12,
      :container         => ".hi"
    }
    embed = DC::Embed::Document.new(resource, Hash[input_config.map{ |k,v| [k, v.to_s] }])
    
    config = embed.embed_config
    input_config.keys.each do |key|
      config[key].must_equal input_config[key]
    end
  end
  
  it "should output to keys the viewer recognizes" do
    
  end
end
