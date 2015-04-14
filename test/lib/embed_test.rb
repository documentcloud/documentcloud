require_relative '../test_helper'

describe DC::Embed do
  it "should require a resource" do
    Proc.new{ DC::Embed.new(nil, {}) }.must_raise ArgumentError
    Proc.new{ DC::Embed.new({}, {})  }.must_raise ArgumentError

    struct = Struct.new(:id).new
    DC::Embed.new(struct, {}).must_be_kind_of DC::Embed
  end
end