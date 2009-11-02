require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  
  EMAIL = 'lmercier@tribune.org'
  
  context "A DocumentCloud Journalist Account" do
    
    subject { Account.find_by_email(EMAIL) }
    
    should_belong_to :organization
    should_have_many :labels
    should_have_many :saved_searches
    should_have_one  :security_key
    
    should "not be able to log in with a bad password" do
      account = Account.log_in(EMAIL, 'nope', {})
      assert !account
    end
    
    should "be able to log in" do
      session = {}
      account = Account.log_in(EMAIL, 'password', session)
      assert account
      assert account.email == EMAIL
      assert session['account_id'] == account.id
    end
    
    should "be able to generate computed attributes" do
      assert subject.full_name == "Louis Mercier"
      assert subject.rfc_email == "\"Louis Mercier\" <#{EMAIL}>"
      assert subject.hashed_email == "ad8a5488a780b768fd04ab4b8e319793"
      assert !subject.pending
    end
    
    should "serialize to json with extra attributes by default" do
      json = JSON.parse(subject.to_json)
      assert json['hashed_email'] == subject.hashed_email
      assert !json['pending']
    end
    
  end
  
end