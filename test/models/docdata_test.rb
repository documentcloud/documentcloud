require 'test_helper'

class DocdataTest < ActiveSupport::TestCase

  def test_it_cant_have_blank_data
    data = Docdata.new( document_id: doc.id, data: {} )
    refute data.save
    refute_empty data.errors[:data]
  end

  def test_it_saves_hashy_strings
    data = Docdata.new( document_id: doc.id, data: "one=>1" )
    assert data.save
    assert_equal( {'one' => '1' }, data.data )
  end

  def test_it_dissallows_bad_keys
    data = Docdata.new( document_id: doc.id, data: { :title=>"a useless title"} )
    refute data.save
    assert_equal ['Invalid data key: title'], data.errors[:base]
  end
end
