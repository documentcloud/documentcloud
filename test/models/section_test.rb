require 'test_helper'

class SectionTest < ActiveSupport::TestCase

  subject { sections(:first) }

  it "has associations and they query successfully" do
    assert_associations_queryable subject
  end

  it "formats canonical url correctly" do
    assert_match %r{368941146-tv.html#document/p1$}, subject.canonical_url
  end


end
