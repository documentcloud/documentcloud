require 'test_helper'

class MembershipTest < ActiveSupport::TestCase


  it "has associations and they query successfully" do
    assert_associations_queryable tribune
  end

  it "has scopes that are queryable" do
    assert_working_relations( Membership, [ :real ] )
  end

  it "has canonical" do
    assert memberships(:louis_tribune).canonical( :include_account=>{} )
  end
end
