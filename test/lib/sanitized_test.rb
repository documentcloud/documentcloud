require_relative '../test_helper'

class SanitizedTest < ActiveSupport::TestCase
  include DC::Sanitized
  
  it "should strip non-characters & replace them with dashes" do
    assert sluggify(%[''(asdf)'''''___⌘⌘⌘\n"lol.wat".。---不]), "asdf-lol-wat-不"
  end
end