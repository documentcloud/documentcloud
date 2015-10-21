require 'test_helper'
require 'dc/import/calais_fetcher'

class CalaisFetcherTest < ActiveSupport::TestCase

  def setup
    @text = "Fair use is a limitation and exception to the exclusive right granted by copyright law to the author of a creative work. In United States copyright law, fair use is a doctrine that permits limited use of copyrighted material without acquiring permission from the rights holders."
  end

  test "Can split text over text size into the correct chunks" do
    small_split = DC::Import::CalaisFetcher.new.split_text("z" * 94000)
    medium_split = DC::Import::CalaisFetcher.new.split_text("z" * 95001)
    huge_split = DC::Import::CalaisFetcher.new.split_text("z" * 200000)
    assert small_split.count == 1 && medium_split.count == 2 && huge_split.count == 3
  end

  test "Can fetch_rdf_from_calais" do
    VCR.use_cassette "open_calais/fetch_rdf_from_calais" do
      fetcher_request = DC::Import::CalaisFetcher.new.fetch_rdf_from_calais(@text)
      assert fetcher_request.entities.present?
    end
  end
end
