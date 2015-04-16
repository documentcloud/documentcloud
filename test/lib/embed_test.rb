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
end
