require 'test_helper'

class PageTest < ActiveSupport::TestCase

  subject { pages(:first) }

  it "has associations and they query successfully" do
    assert_associations_queryable subject
  end

  it "searches for page numbers" do
    pages = Page.search_for_page_numbers( 'written', doc)
    assert pages
  end

end
