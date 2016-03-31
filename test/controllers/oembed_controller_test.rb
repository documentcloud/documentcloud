require 'test_helper'

class OembedControllerTest < ActionController::TestCase
  
  tests ApiController

  include Rails.application.routes.url_helpers
  default_url_options[:host] = DC::CONFIG['server_root']

  let(:public_document_url) { CGI.escape(documents(:tv_manual).canonical_url) }
  let(:missing_url) { CGI.escape(url_for controller: 'documents', action: 'show', id: '3-the-magic-number', format: 'html') }
  let(:unsupported_format_url) { CGI.escape(documents(:tv_manual).canonical_url(:json)) }
  let(:external_url) { CGI.escape('http://www2.warnerbros.com/spacejam/movie/jam.htm') }

  it "should understand a valid oEmbed request" do
    get :oembed, format: "json", url: public_document_url
    assert_response :success
    assert_equal 'rich', json_body['type']
    assert_equal '1.0', json_body['version']
    assert_equal DC.server_root, json_body['provider_url']
  end

  it "should require a URL parameter" do
    get :oembed, format: "json"
    assert_response 400
  end

  it "shouldn't support wacky formats" do
    get :oembed, format: "lol", url: public_document_url
    assert_response 501
  end

  it "shouldn't find URLs from non-DocumentCloud domains" do
    get :oembed, format: "json", url: external_url
    assert_response 404
  end

  it "shouldn't find unsupported URLs" do
    skip "Need to reimplement this check"
    get :oembed, format: "json", url: unsupported_format_url
    assert_response 404
  end

  it "shouldn't find resources that don't exist" do
    skip "Not yet implemented missing resource check"
    get :oembed, format: "json", url: missing_url
    assert_response 404
  end

end
