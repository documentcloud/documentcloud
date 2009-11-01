require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  
  context "A DocumentCloud Journalist Account" do
    
    should_belong_to :organization
    should_have_many :labels
    should_have_many :saved_searches
    should_have_one  :security_key
    
    should "not be able to log in with a bad password" do
      account = Account.log_in('lmercier@tribune.org', 'nope', {})
      assert !account
    end
    
    should "be able to log in" do
      session = {}
      account = Account.log_in('lmercier@tribune.org', 'password', {})
      assert account
    end
    
  end
  
end