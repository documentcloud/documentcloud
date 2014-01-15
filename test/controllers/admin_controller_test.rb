require 'test_helper'

class AdminControllerTest < ActionController::TestCase

  def test_it_creates_account
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

end
