require 'test_helper'

class PhoneExtractorTest < ActiveSupport::TestCase

  DOC = <<-EOS
    Lorem ipsum January sit 800-555-1212, consectetuer adipiscing elit, sed
    diam nonummy nibh euismod tincidunt ut 7 dolore magna
    aliquam 12 800 555 1212. Ut wisi enim ad minim veniam, quis
    nostrud exerci tation ullamcorper 800.555.1212 lobortis nisl ut
    (800) 555-1212 January 2, 1419 ea commodo 21. Duis autem vel March iriure
    dolor in hendrerit in 1-800-555-1212 velit esse molestie 6/1/09 consequat,
    vel 800-555-1212x1234 dolore eu 2247-10-11 800-555-1212 #1234.
  EOS

  NUMBERS = ['(800) 555-1212', '(800) 555-1212 x1234']

  it "be able to correctly extract phone numbers from text" do
      numbers = DC::Import::PhoneExtractor.new.extract_phone_numbers(DOC)
      assert numbers.map {|d| d[:number] }.sort == NUMBERS.sort
      assert numbers.first[:occurrences].length == 5
      assert numbers.last[:occurrences].length  == 2
  end


end
