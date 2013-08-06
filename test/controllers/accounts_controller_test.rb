require 'test_helper'

class AccountsControllerTest < ActionController::TestCase


  it "can enable accounts" do
    account = Account.create( email:'test@test.com', first_name: 'Test', last_name: 'Tester' )
    refute account.security_key
    account.create_security_key
    assert account.security_key && account.security_key.securable
    post :enable, { :key=>account.security_key.key,:acceptance=>true, :password=>'none' }
    assert_redirected_to '/'
    assert_nil account.reload.security_key
    assert Account.log_in( account.email, 'none' )
  end

  it "can reset an account" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post :reset, :email=>louis.email
    end
    assert assigns(:success)
  end

  it "returns json accounts" do
    login_account!
    resp = get :index
    assert_response :success
    accounts = ActiveSupport::JSON.decode(resp.body)
    assert accounts.detect{|acct| acct['id'] == louis.id }, 'Account is present'
  end

  it "tests for logged_in" do
    get :logged_in
    assert_response 400
    get :logged_in, :format=>'js'
    assert_response :success
    assert_kind_of FalseClass, json_body['logged_in']
    login_account!
    get :logged_in, :format=>'js'
    assert_kind_of TrueClass, json_body['logged_in']
  end

  it "requires admin for creation can create accounts" do
    login_account!('reporter_joe')

    post :create
    assert_response 403
  end

  it "can create accounts" do
    login_account!(:louis)
    assert_raises(ActionController::ParameterMissing){
      post :create
    }

  end


end
