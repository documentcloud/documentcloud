require_relative '../test_helper'
require 'pry'

describe DC::Embed do
  
  let(:resource) { Struct.new(:id, :url).new("1235", "https://lol.wat/1235") }
  
  it "should require a resource" do
    Proc.new{ DC::Embed.new(nil, {}) }.must_raise ArgumentError
    Proc.new{ DC::Embed.new({}, {})  }.must_raise ArgumentError

    DC::Embed.new(resource, {}).must_be_kind_of DC::Embed
  end
  
  it "should output HTML markup"
  it "should output an oembed response as json"
  it "should output a JST template"
end