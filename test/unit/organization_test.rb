require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
    
  context "An Organization" do
        
    should_have_many :accounts
    
  end
  
end