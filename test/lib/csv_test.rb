require 'test_helper'

class CSVTest < ActiveSupport::TestCase

  def test_generation
    keys = [ :id, :account_id, :title, :slug ]
    csv = DC::CSV::generate_csv( Document.all.as_json, keys )
    data = CSV.parse( csv )
    assert_equal Document.count+1, data.length
    assert_equal data.first, keys.map(&:to_s)
  end
end
