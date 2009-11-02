require 'test_helper'

class MetadatumTest < ActiveSupport::TestCase
    
  context "A Metadatum" do
        
    should_belong_to :account
    
    should "only be able to save unique document ids" do
      label = Account.first.labels.create(:title => "l", :document_ids => '101,20,101,20')
      assert label.document_ids == '101,20'
    end
    
  end
  
end