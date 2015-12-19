require 'test_helper'

class AdminControllerTest < ActionController::TestCase

  let(:read_only?) { Rails.application.config.read_only }

  it "responds to read-only mode" do
    get :index
    assert_response 403
    login_account! :admin
    get :signup
    assert_response read_only? ? 503 : :success
  end

  # Tests that don't matter in read-only mode
  unless Rails.application.config.read_only

    it "creates account" do
      login_account! :admin
      assert accounts(:admin).dcloud_admin?
      params = {
        "organization"=>{"name"=>"nathan",
                         "slug"=>"testing",
                         "language"=>"eng",
                         "document_language"=>"eng"},
        "account"=>{"email"=>"foo+nathan@documentcloud.org",
                    "first_name"=>"test",
                    "last_name"=>"bob"}}
      post :signup, params
      assert_response :success
      assert Organization.where( :slug=>'testing' ).first
      assert Account.where( "email"=>"foo+nathan@documentcloud.org" ).first
    end

    it "checks for existing accounts" do
      login_account! :admin
      params = {
        "organization"=>{"name"=>"nathan",
                         "slug"=>"testing",
                         "language"=>"eng",
                         "document_language"=>"eng"},
        "account"=>{"email"=>louis.email,
                    "first_name"=>"test",
                    "last_name"=>"bob"}}
      post :signup, params
      assert_match louis.email, flash[:error]
      assert_nil Organization.where( :slug=>'testing' ).first
    end

    it "moves accounts" do
      login_account! :admin
      params = {
        "move_account"=>"t",
        "organization"=>{"name"=>"nathan",
                         "slug"=>"testing",
                         "language"=>"eng",
                         "document_language"=>"eng"},
        "account"=>{"email"=>louis.email,
                    "first_name"=>"test",
                    "last_name"=>"bob"}}
      assert_difference ->{ Organization.count }, 1 do
        post :signup, params
      end
      assert_nil flash[:error]
      org = Organization.find_by_slug('testing')
      louis.memberships(true)

      assert_equal 2, louis.memberships.count
      assert louis.memberships.where(organization: tribune, default:false).any?
      assert louis.memberships.where(organization: org, default:true).any?
    end

  end

end
