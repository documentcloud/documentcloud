require_relative '../test_helper'

class SanitizedTest < ActiveSupport::TestCase
  include DC::Sanitized
  
  it "should strip non-characters & replace them with dashes" do
    assert_equal "asdf-lol-wat-不", sluggify(%[''(asdf)'''''___⌘⌘⌘\n"lol.wat".。---不])
  end

  # Make sure characters from outside our intended unicode range are being 
  # removed, as supporting them requires changes to our non-Ruby patterns
  it "should not support full 21-bit Unicode dictionary" do
    assert_equal "hi-kitty", sluggify("hi kitty 😺")
  end

end