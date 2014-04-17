require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase


  it "has associations and they query successfully" do
    assert_associations_queryable tribune
  end

  it "chooses a default" do
    assert_equal tribune, Organization.default_for( louis )
  end

  it "adds names to documents" do
    assert_equal tribune.name, Organization.names_for_documents( [ doc ] )[ tribune.id ]
  end

  it "lists public organizations" do
    assert Organization.listed.detect{ |org| org == tribune }
  end

  it "retrieves slugs" do
    refute_empty Organization.all_slugs
  end

  it "populates member info" do
    orgs = Organization.populate_members_info( Organization.all)
    assert trib = orgs.detect{|org| org == tribune }
    assert trib.members.detect{|member| member['slug'] == louis.slug }
  end

  it "excludes accounts from member info" do
    orgs = Organization.populate_members_info( Organization.all, louis)
    refute orgs.detect{|org| org == tribune }.members.detect{|member| member['slug'] == louis.slug }
  end

  it "counts documents" do
    assert_equal 2, tribune.document_count
  end

  it "returns an accounts role" do
    assert tribune.role_of( louis )
    assert_equal Account::ADMINISTRATOR, tribune.role_of( louis ).role
  end

  it "can add members" do
    membership = tribune.add_member( accounts(:freelancer_bob), Account::ADMINISTRATOR)
    refute_nil membership
    assert_equal membership.role, Account::ADMINISTRATOR
  end

  it "can remove members" do
    tribune.remove_member( joe )
    assert_empty joe.reload.memberships
    refute tribune.memberships.where({ :account_id=>joe.id }).exists?
    assert tribune.memberships.where({ :account_id=>louis.id }).exists?
  end

  it "finds admin emails" do
    assert_equal [louis.email], tribune.admin_emails
  end


end
