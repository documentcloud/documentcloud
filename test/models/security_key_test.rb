require 'test_helper'

class SecurityKeyTest < ActiveSupport::TestCase
    
  context "A SecurityKey" do
        
    should_belong_to :securable
    
    should "be able to access an account through a security key" do
      account = Account.first
      seckey = account.create_security_key(:key => 'secret_stuff')
      assert seckey.valid?
      assert seckey == 'secret_stuff'
    end
    
  end
  
end