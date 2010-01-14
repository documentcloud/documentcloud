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

  DATES = [Date.parse('2004-12-10'), Date.parse('1419-1-2'), Date.parse('2009-6-1')]

  context "The DateExtractor" do

    should "be able to correctly extract dates from text" do
      dates = DC::Import::DateExtractor.new.extract_dates(DOC).map {|d| d[:date] }
      assert dates.sort == DATES.sort
    end

  end

end