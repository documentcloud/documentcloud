require 'test_helper'

class AjaxHelpControllerTest < ActionController::TestCase

  it "sends contact emails" do
    login_account!
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      get :contact_us, :message=>'Wake Up!'
    end
    mail = ActionMailer::Base.deliveries.last
    assert_equal ['support@documentcloud.org'], mail.to
    assert_equal [louis.email], mail.reply_to
    assert_match( /Wake Up!/, mail.body.to_s )
  end

end
