require 'test_helper'

class AuthenticationControllerTest < ActionController::TestCase

  let(:read_only?) { Rails.application.config.read_only }

  it "responds to read-only mode" do
    get :iframe
    assert_response read_only? ? 503 : :success
  end

  def test_redirects_to_home_for_logged_accounts_attempting_to_login
    get :login
    assert_template "login"
    login_account!
    get :login
    assert_redirected_to '/'
  end

  def test_logins_a_user
    post :login, :email=>louis.email, :password=>'password', :next=>'/foo'
    assert_redirected_to '/foo'
  end

  def test_displays_error_on_bad_login
    post :login, :email=>louis.email, :password=>'badpass', :next=>'/foo'
    assert_match( /invalid/i, flash[:error] )
    louis.memberships.first.update_attributes :role=>Account::DISABLED
    post :login, :email=>louis.email, :password=>'password', :next=>'/foo'
    assert_match( /disabled/i, flash[:error] )
  end

  def test_logout
    session['account_id']=louis.id
    get :logout
    assert_nil session['account_id']
  end
end
