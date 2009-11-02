require 'test_helper'

class SavedSearchTest < ActiveSupport::TestCase
    
  context "A Saved Search" do
        
    should_belong_to :account
    
  end
  
end