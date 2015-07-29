require 'test_helper'

class CalaisFetcherTest < ActiveSupport::TestCase

  test "Can fetch RDF from OpenCalais" do
    fetcher_request = CalaisFetcher.new.fetch_rdf("DocumentCloud is a tool that changed my life last Friday.")
    assert fetcher_request.present?
  end
end
