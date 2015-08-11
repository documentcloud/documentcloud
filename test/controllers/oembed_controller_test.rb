require 'test_helper'

class OembedControllerTest < ActionController::TestCase
  
  tests ApiController

  include Rails.application.routes.url_helpers
  default_url_options[:host] = DC::CONFIG['server_root']

  let(:valid_resource_url) { CGI.escape(url_for :controller => 'documents', :action => 'show', :id => '1-is-the-lonelist-number', :format => 'html') }
  let(:missing_resource_url) { CGI.escape(url_for :controller => 'documents', :action => 'show', :id => '3-the-magic-number', :format => 'html') }
  let(:unsupported_resource_url) { CGI.escape(url_for :controller => 'home', :action => 'index') }
  let(:external_resource_url) { CGI.escape('http://www2.warnerbros.com/spacejam/movie/jam.htm') }

  def test_oembed_response
    get :oembed, :format => "json", :url => valid_resource_url
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
    get :oembed, :format => "lol", :url => valid_resource_url
    assert_response 501
  end

  def test_wrong_domain
    get :oembed, :format => "json", :url => external_resource_url
    assert_response 404
  end

  def test_unsupported_resource
    get :oembed, :format => "json", :url => unsupported_resource_url
    assert_response 404
  end

  def test_missing_resource
    skip "Not yet implemented missing resource check"
    get :oembed, :format => "json", :url => missing_resource_url
    assert_response 404
  end
end
