require 'test_helper'

class EntityDateTest < ActiveSupport::TestCase

  let (:jan) { entity_dates(:jan1) }
  let (:dec) { entity_dates(:dec24) }

  it "has associations and they query successfully" do
    assert_associations_queryable jan
  end

  it "can be reset" do
    assert_equal [jan,dec], doc.entity_dates
    EntityDate.reset( doc )
    assert_equal Date.new(1851,10,18), doc.entity_dates.first.date
  end

  it "can render json" do
    jan.to_json(:include_excerpts=>true)
    data = ActiveSupport::JSON.decode jan.to_json(:include_excerpts=>true)
    assert data['excerpts']
  end

end
