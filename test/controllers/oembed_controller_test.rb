require 'test_helper'

class OembedControllerTest < ActionController::TestCase
  
  tests ApiController

  include Rails.application.routes.url_helpers
  default_url_options[:host] = DC::CONFIG['server_root']

  # TODO: Clean up all these [JR]
  let(:valid_resource_url) { CGI.escape(url_for :controller => 'documents', :action => 'show', :id => '1-is-the-lonelist-number', :format => 'html') }
  let(:unicode_resource_url) { CGI.escape(url_for :controller => 'documents', :action => 'show', :id => '2-不', :format => 'html') }
  let(:missing_resource_url) { CGI.escape(url_for :controller => 'documents', :action => 'show', :id => '3-the-magic-number', :format => 'html') }
  let(:unsupported_resource_url) { CGI.escape(url_for :controller => 'home', :action => 'index') }
  let(:external_resource_url) { CGI.escape('http://www2.warnerbros.com/spacejam/movie/jam.htm') }
  let(:public_document_url) { CGI.escape(documents(:tv_manual).canonical_url(:html)) }
  let(:private_document_url) { CGI.escape(documents(:top_secret).canonical_url(:html)) }
  let(:missing_url) { CGI.escape(url_for controller: 'documents', action: 'show', id: '404-not-found', format: 'html') }
  let(:unsupported_format_url) { CGI.escape(documents(:tv_manual).canonical_url(:lol)) }
  let(:external_url) { CGI.escape('http://www2.warnerbros.com/spacejam/movie/jam.htm') }

  it "should understand a valid oEmbed request" do
    get :oembed, format: "json", url: public_document_url
    assert_response :success
    assert_equal 'rich', json_body['type']
    assert_equal '1.0', json_body['version']
    assert_equal DC.server_root, json_body['provider_url']
  end

  it "should correctly parse Unicode slugs" do
    get :oembed, :format => "json", :url => unicode_resource_url
    assert_response :success
  end

  it "should require a URL parameter" do
    get :oembed, format: "json"
    assert_response 400
  end

  it "shouldn't find private documents" do
    get :oembed, format: "json", url: private_document_url
    assert_response 403
  end

  it "shouldn't support wacky oEmbed response formats" do
    get :oembed, format: "lol", url: public_document_url
    assert_response 501
  end

  it "shouldn't find URLs from non-DocumentCloud domains" do
    get :oembed, format: "json", url: external_url
    assert_response 404
  end

  it "should only find HTML resources" do
    get :oembed, format: "json", url: unsupported_format_url
    assert_response 404
  end

  it "shouldn't find resources that don't exist" do
    skip "Not yet implemented missing resource check"
    get :oembed, format: "json", url: missing_url
    assert_response 404
  end

end
