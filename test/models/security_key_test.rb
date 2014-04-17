require 'test_helper'

class SecurityKeyTest < ActiveSupport::TestCase

  subject { SecurityKey.new }


  it "compares to others" do
    louis.create_security_key
    refute_equal subject, accounts(:louis).security_key
  end

  it "can access an account through a security key" do
    account = Account.first
    seckey = account.create_security_key(:key => 'secret_stuff')
    assert seckey.valid?
    assert seckey == 'secret_stuff'
  end

end
