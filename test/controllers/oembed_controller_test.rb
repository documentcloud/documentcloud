require 'test_helper'

class OembedControllerTest < ActionController::TestCase
  
  tests ApiController

  def test_oembed_response
    get :oembed, :format => "json", :url => CGI.escape("https://www.documentcloud.org/help")
    assert_response :success
    assert_equal 'rich', json_body['type']
    assert_equal '1.0', json_body['version']
    assert_equal DC.server_root, json_body['provider_url']
  end

  def test_missing_url_param
    get :oembed, :format => "json"
    assert_response 400
  end

  def test_unsupported_format
    get :oembed, :format => "lol", :url => CGI.escape("https://www.documentcloud.org/help")
    assert_response 501
  end

end