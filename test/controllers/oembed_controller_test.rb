require 'test_helper'

class OembedControllerTest < ActionController::TestCase
  
  tests ApiController

  include Rails.application.routes.url_helpers
  default_url_options[:host] = DC::CONFIG['server_root']

  def test_oembed_response
    url = CGI.escape(url_for :controller => 'workspace', :action => 'help')
    get :oembed, :format => "json", :url => url
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
    url = CGI.escape(url_for :controller => 'workspace', :action => 'help')
    get :oembed, :format => "lol", :url => url
    assert_response 501
  end

end