require 'test_helper'

class FeaturedReportTest < ActiveSupport::TestCase

  MARKDOWN =<<EOS
A title
-----------------------------------
**bolded!**   ***Bold***
EOS

  HTML =<<EOS
<h2>A title</h2>

<p><strong>bolded!</strong>   <strong><em>Bold</em></strong></p>
EOS

  it "encodes with markdown" do
    fr = FeaturedReport.new( :writeup => MARKDOWN )
    assert_equal HTML, fr.writeup_html
    assert_equal HTML, fr.as_json['writeup_html']
  end


end
