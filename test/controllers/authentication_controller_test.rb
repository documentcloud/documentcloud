require 'test_helper'

class AuthenticationControllerTest < ActionController::TestCase

  test "signup_info" do
    get :signup_info
    assert_template layout: "workspace.html.erb"
  end

  it "redirects to home for logged accounts attempting to login" do
    get :login
    assert_template "login"
    login_account!
    get :login
    assert_redirected_to '/'
  end

  it "logins a user" do
    post :login, :email=>louis.email, :password=>'password', :next=>'/foo'
    assert_redirected_to '/foo'
  end

  it "displays error on bad login" do
    post :login, :email=>louis.email, :password=>'badpass', :next=>'/foo'
    assert_match( /invalid/i, flash[:error] )
    louis.memberships.first.update_attributes :role=>Account::DISABLED
    post :login, :email=>louis.email, :password=>'password', :next=>'/foo'
    assert_match( /disabled/i, flash[:error] )
  end

  test "logout" do
    session['account_id']=louis.id
    get :logout
    assert_nil session['account_id']
  end

  it "logs in from omniauth callback" do
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
