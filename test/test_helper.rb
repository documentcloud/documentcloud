ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'
require 'sunspot_matchers/test_helper'
require 'turn/autorun'

 require "minitest/autorun"
 require 'pry'

PROCESSING_JOBS = []

Turn.config do |c|
  # use one of output formats:
  # :outline  - turn's original case/test outline mode [default]
  # :progress - indicates progress with progress bar
  # :dotted   - test/unit's traditional dot-progress mode
  # :pretty   - new pretty reporter
  # :marshal  - dump output as YAML (normal run mode only)
  # :cue      - interactive testing
  c.format  = :pretty
  # turn on invoke/execute tracing, enable full backtrace
  c.trace   = 3
  # use humanized test names (works only with :outline format)
  c.natural = true
end


module DocumentCloudAssertions
  def self.included(base)
    base.send :include,  SunspotMatchers::TestHelper
    base.setup do
      Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
    end
    base.teardown do
      PROCESSING_JOBS.clear
    end
  end

  def assert_job_action( action )
    assert PROCESSING_JOBS.detect{ | job | job['action'] == action }, "no job #{action} was ran"
  end

end

class ActionController::TestCase
  include DocumentCloudAssertions

  def login_account!( login = :louis, password='password' )
    account = accounts(login)
    @request.headers['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic
      .encode_credentials( account.email, password )
    @request.session['account_id']      = account.id,
    @request.session['organization_id'] = account.organization_id
  end

  def json_body
    ActiveSupport::JSON.decode(@response.body)
  end

  def cors_allowed_methods
    response.headers['Access-Control-Allow-Methods'].split(/,\s*/)
  end

  def cors_allowed_headers
    response.headers['Access-Control-Allow-Headers'].split(/,\s*/)
  end


end


class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!
  include DocumentCloudAssertions

  fixtures :all

  let (:doc) { documents(:tv_manual) }
  let (:secret_doc){ documents(:top_secret)}
  let (:louis){ accounts(:louis) }
  let (:tribune){ louis.organization }
  let (:joe) { accounts(:reporter_joe) }

  # Add more helper methods to be used by all tests here...

  def assert_working_relations( model, relations )
    failed = []
    relations.each do | name |
      begin
        model.send( name )
      rescue Exception => e
        failed << "#{name} - #{e}"
      end
    end
    if failed.empty?
      assert true
    else
      assert false, failed.join('; ')
    end
  end

  def assert_associations_queryable( model )
    assert_working_relations( model, model.class.reflect_on_all_associations.map{|association| association.name } )
  end

end


class ActionController::TestRequest
  def ssl?
    true
  end
end


class Document
  def background_update_asset_access(access_level)
    self.update_attributes :access => access_level
  end
end

module RestClient
  class DummyResponse
    def initialize(url,json)
      job = ActiveSupport::JSON.decode( json[:job] )
      job['id'] = rand(100).to_s
      PROCESSING_JOBS.push( job )
      @url=url; @json={ :job => job.to_json }
    end
    def body
      @json
    end
  end
  def self.post( url, json )
    DummyResponse.new(url, json)
  end
end


class DC::Import::PDFWrangler
  def ensure_pdf(file,name)
    yield Tempfile.new(file)
  end
end

class DC::Store::AssetStore
  def save_insert_pdf(doc, path, file )
  end
end
