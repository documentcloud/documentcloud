require 'test_helper'

class AccountsControllerTest < ActionController::TestCase

  let(:read_only?) { Rails.application.config.read_only }

  it "responds to read-only mode" do
    get :index
    assert_response 403
    get :enable
    assert_response read_only? ? 503 : :success
  end

  it "has proper routes" do
    assert_recognizes({ controller: 'accounts', action: 'index' }, '/accounts')
    assert_recognizes({ controller: 'accounts', action: 'logged_in' }, '/accounts/logged_in')
    assert_recognizes({ controller: 'accounts', action: 'resend_welcome', id: '2' }, '/accounts/resend_welcome/2')
    assert_recognizes({ controller: 'accounts', action: 'enable', key: '2' }, { path: '/accounts/enable/2', method: :post })
    assert_recognizes({ controller: 'accounts', action: 'enable', key: '2' }, { path: '/accounts/enable/2', method: :get })
    assert_recognizes({ controller: 'accounts', action: 'reset' }, { path: '/reset_password', method: :get } )
    assert_recognizes({ controller: 'accounts', action: 'reset' }, { path: '/reset_password', method: :post } )
  end

  it "returns accounts as json" do
    login_account!
    resp = get :index, :format=>:json
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

  it "can resend welcome email" do
    login_account!(:louis)
    post :resend_welcome, :id=>joe.id
    assert_response 200
    refute_empty ActionMailer::Base.deliveries
    mail = ActionMailer::Base.deliveries.last
    assert_equal [joe.email], mail.to
    assert_match( joe.security_key.key, mail.body.to_s )
  end

  # Tests that don't matter in read-only mode
  unless Rails.application.config.read_only

    it "can enable accounts" do
      account = Account.create( email:'test@test.com', first_name: 'Test', last_name: 'Tester',
                                :language=>'spa', :document_language=>"spa" )
      refute account.security_key
      account.create_security_key
      assert account.security_key && account.security_key.securable
      post :enable, { :key=>account.security_key.key, :acceptance=>true, :password=>'none' }
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

    it "can create accounts" do
      login_account!(:louis)
      assert_difference('Account.count',1) do
        post :create, :first_name=>'John', :last_name=>'Snow', :email=>'jsnow@winterfell.org', :language=>'spa', :document_language=>"spa"
      end
    end

    it "can update an account" do
      login_account!(:louis)
      post :update, :id=>joe.id, :first_name=>'Bob'
      assert_equal 'Bob', joe.reload.first_name
      post :update, :id=>joe.id, :role=>Account::ADMINISTRATOR
      assert_equal Account::ADMINISTRATOR, joe.reload.role
    end

    it "requires admin for modification of accounts" do
      login_account!('reporter_joe')
      post :create
      assert_response 403
      post :update, :id=>louis.id
      assert_response 403
      post :update, :id=>joe.id
      assert_response 200

      get :resend_welcome
      assert_response 403

      delete :destroy
      assert_response 403
    end

    it "can only update current users password" do
      login_account!(:louis)

      post :update, :id=>joe.id, :password=>'topsecret'
      refute Account.log_in( joe.email, 'topsecret')

      post :update, :id=>louis.id, :password=>'topsecret'
      assert_equal louis, Account.log_in( louis.email, 'topsecret')
    end

    it "can (kind of) destroy accounts" do
      login_account!(:louis)
      delete :destroy, :id=>joe.id
      assert_response 200
      assert_equal Account::DISABLED, joe.role
    end

    it "sends an error messages when email is not valid" do
      login_account!(:louis)
      assert_difference('Account.count',0) do
        response = post :create, :first_name=>'Crazy', :last_name=>'Email', :email=>'crazy*{}**email@test.com', :language=>'eng', :document_language=>"eng"
        assert_response 400
        message = ActiveSupport::JSON.decode(response.body)
        assert_equal ["Email is invalid"], message['errors']
      end
    end

  end

end
