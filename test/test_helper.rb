ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'
require 'minitest/emoji'

require 'sunspot_matchers_testunit'

PROCESSING_JOBS = []

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  include SunspotMatchersTestunit

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  let (:doc) { documents(:tv_manual) }
  let (:secret_doc){ documents(:top_secret)}
  let (:louis){ accounts(:louis) }
  let (:tribune){ louis.organization }
  let (:joe) { accounts(:reporter_joe) }

  # Add more helper methods to be used by all tests here...

  def setup
    Sunspot.session = SunspotMatchersTestunit::SunspotSessionSpy.new(Sunspot.session)
  end
  def teardown
    PROCESSING_JOBS.clear
  end

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

  def assert_job_action( action )
    assert PROCESSING_JOBS.detect{ | job | job['action'] == action }, "no job #{action} was ran"
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
      PROCESSING_JOBS.push( ActiveSupport::JSON.decode(json[:job] ) )
      @url=url; @json=json
    end
    def body
      @json
    end
  end
  def self.post( url, json )
    DummyResponse.new(url, json)
  end
end
