require 'test_helper'

class PageTest < ActiveSupport::TestCase

  subject { pages(:second) }

  it "has associations and they query successfully" do
    assert_associations_queryable subject
  end

  it "searches for page numbers" do
    pages = Page.search_for_page_numbers( 'written', doc)
    assert pages
  end

  it "refreshes page map" do
    fixture_offset = subject.start_offset
    Page.refresh_page_map( doc )
    subject.reload
    refute_equal fixture_offset, subject.start_offset
    assert_equal pages(:first).text.length, subject.start_offset
  end

  it "generates 'mentions'" do
    mentions = Page.mentions( doc.id,'Ishmael')
    assert_equal mentions[:total], 1
    assert_equal mentions[:mentions].first, {:page=>1, :text=>"Call me <b>Ishmael</b>."}
  end

end
