require 'test_helper'

class DateExtractorTest < ActiveSupport::TestCase

  DOC = <<-EOS
    Lorem ipsum January sit 12.10.2004, consectetuer adipiscing elit, sed
    diam nonummy nibh euismod tincidunt ut 7 dolore magna
    aliquam 12 volutpat. Ut wisi enim ad minim veniam, quis
    nostrud exerci tation ullamcorper suscipit lobortis nisl ut
    aliquip January 2, 1419 ea commodo 21. Duis autem vel March iriure
    dolor in hendrerit in vulputate velit esse molestie 6/1/09 consequat,
    vel illum dolore eu 2247-10-11.
  EOS

  DATES = [Date.parse('2004-12-10'), Date.parse('1419-1-2')]

  it "correctly extracts dates from text" do
    dates = DC::Import::DateExtractor.american.extract_dates(DOC).map {|d| d[:date] }
    assert_equal dates.sort, DATES.sort
  end

  it "parses US dates" do
    parser = DC::Import::DateExtractor.american
    assert_equal Date.new(2010,10,30), parser.extract_dates('10-30-2010').first[:date]
    assert_equal Date.new(2010,12,30), parser.extract_dates('2010-12-30').first[:date]
    assert_equal Date.new(2010,5,6), parser.extract_dates('5/6/2010').first[:date]
  end

  it "parses international dates" do
    parser = DC::Import::DateExtractor.international
    assert_equal Date.new(2010,10,30), parser.extract_dates('30-10-2010').first[:date]
    assert_equal Date.new(2010,12,30), parser.extract_dates('2010-12-30').first[:date]
    assert_equal Date.new(2010,5,6), parser.extract_dates('6/5/2010').first[:date]
  end


end
