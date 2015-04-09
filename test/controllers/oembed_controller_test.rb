require 'test_helper'

class OembedControllerTest < ActionController::TestCase
  
  tests ApiController

  def test_oembed_response
    get :oembed
    assert_response :success
    assert_equal 'rich', json_body['type']
    assert_equal '1.0', json_body['version']
    assert_equal DC.server_root, json_body['provider_url']
  end

end