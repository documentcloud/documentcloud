require 'test_helper'

class AuthenticationControllerTest < ActionController::TestCase

  def test_signup_info
    get :signup_info
    assert_template layout: "workspace.html.erb"
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

  def test_logs_in_from_omniauth_callback
    request.env['omniauth.auth'] = {
      'provider' => 'twitter',
      'uid' => '424',
      'info' =>{
        'email' => 'test@test.com',
        'name'  => 'Testing Tester'
      }
    }
    assert_difference( 'Account.count' ) do
      get :callback
    end
    account = Account.where( email: 'test@test.com' ).first
    assert_equal 'Testing', account.first_name
  end

end
