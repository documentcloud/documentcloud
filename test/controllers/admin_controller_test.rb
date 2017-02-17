require 'test_helper'

class AdminControllerTest < ActionController::TestCase

  let(:read_only?) { Rails.application.config.read_only }

  it "responds to read-only mode" do
    get :index
    assert_response 403
    login_account! :admin
    get :add_organization
    assert_response read_only? ? 503 : :success
  end

  # Tests that don't matter in read-only mode
  unless Rails.application.config.read_only

    it "creates new account and organization" do
      login_account! :admin
      params = {
        organization: {
          name:              'Testing',
          slug:              'testing',
          language:          'eng',
          document_language: 'eng',
        },
        account: {
          email:      'testing@dcloud.org',
          first_name: 'Test',
          last_name:  'Tester',
        }
      }
      post :add_organization, params
      assert_response :success
      account      = Account.where(email: 'testing@dcloud.org').first
      organization = Organization.where(slug: 'testing').first
      membership   = account.memberships.where(organization_id: organization.id)
      assert organization
      assert account
      assert membership
      assert membership.default
    end

    it "bails on new account if org has errors" do
      login_account! :admin
      params = {
        organization: {
          name:              tribune.name,
          slug:              tribune.slug,
          language:          'eng',
          document_language: 'eng',
        },
        account: {
          email:      'testing@dcloud.org',
          first_name: 'Test',
          last_name:  'Tester',
        }
      }
      post :add_organization, params
      assert_response :success
      account = Account.where(email: 'testing@dcloud.org').first
      assert_not account
      assert flash[:error]
    end

    it "creates new org and adds existing account" do
      login_account! :admin
      assert_equal 1, louis.memberships.count
      params = {
        organization: {
          name:              'Testing',
          slug:              'testing',
          language:          'eng',
          document_language: 'eng',
        },
        account: {
          email:      louis.email,
          first_name: louis.first_name,
          last_name:  louis.last_name,
        }
      }
      post :add_organization, params
      assert_response :success
      organization = Organization.where(slug: 'testing').first
      membership   = louis.memberships.where(organization: organization).first
      assert organization
      assert membership
      assert_not membership.default
      assert_equal 2, louis.memberships.count
    end

    it "creates new org, adds existing account, makes it default" do
      login_account! :admin
      assert_equal 1, louis.memberships.count
      params = {
        organization: {
          name:              'Testing',
          slug:              'testing',
          language:          'eng',
          document_language: 'eng',
        },
        account: {
          email:      louis.email,
          first_name: louis.first_name,
          last_name:  louis.last_name,
        },
        authorize: 'y'
      }
      post :add_organization, params
      assert_response :success
      organization = Organization.where(slug: 'testing').first
      membership   = louis.memberships.where(organization: organization)
      assert organization
      assert membership
      assert membership.default
      assert_equal 2, louis.memberships.count
    end

  end

end
