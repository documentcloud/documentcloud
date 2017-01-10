require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  it "should not be able to log in with a bad password" do
    account = Account.log_in( louis.email, 'nope', {})
    refute account
  end

  it "retrieves names for documents" do
    docs = [ doc, secret_doc ]
    ids = Account.names_for_documents( docs )
    assert_equal "Louis Mercier", ids[ louis.id ]
  end

  it "has associations and they query successfully" do
    assert_associations_queryable louis
  end

  it "has scopes and they work" do
    assert_includes Account.admin, louis
    assert_includes Account.active, louis
    assert_includes Account.real, louis
    refute_includes Account.reviewer, louis
  end

  it "should be able to log in" do
    session = {}
    account = Account.log_in( louis.email, 'password', session, {})
    assert account
    assert account.email == louis.email
    assert session['account_id'] == account.id
  end

  it "does generate computed attributes" do
    assert louis.full_name == "Louis Mercier"
    assert louis.rfc_email == "\"Louis Mercier\" <#{louis.email}>"
    assert louis.hashed_email == "ad8a5488a780b768fd04ab4b8e319793"
    assert !louis.pending?
  end

  it "serializes json with extra attributes by default" do
    json = JSON.parse(louis.to_json)
    assert json['hashed_email'] == louis.hashed_email
    assert !json['pending']
  end

  it "loads default membership" do
    assert_equal [memberships(:louis_tribune)], louis.memberships
    assert_equal tribune,       louis.organization
  end

  it "makes a slug" do
    assert_equal '380424410-louis-mercier', Account.make_slug( louis )
  end

  it "tests for membership" do
    assert louis.has_memberships?
    assert louis.member_of?( tribune )
    refute louis.member_of?( organizations(:bankrupt) )
  end

  it "checks roles" do
    joe = accounts(:reporter_joe)

    assert louis.has_role?( Account::ADMINISTRATOR )
    assert louis.admin?
    assert louis.admin?( tribune )
    refute louis.admin?( organizations(:bankrupt) )

    assert louis.allowed_to_edit_account?( joe )
    # joe's not an admin but can edit his account
    assert joe.contributor?
    assert joe.allowed_to_edit_account?( joe )
    refute joe.allowed_to_edit_account?( louis )
  end

  it "delivers account emails" do
    louis.send_login_instructions
    mail = ActionMailer::Base.deliveries.last
    assert mail
    assert_equal [LifecycleMailer::SUPPORT], mail.from
    assert_equal [louis.email], mail.to
    assert_match louis.security_key.key, mail.body.to_s

    louis.send_reset_request
    mail = ActionMailer::Base.deliveries.last
    assert_match louis.security_key.key, mail.body.to_s
  end

  it "upgrades a reviewer account" do
    account = accounts(:reporter_joe)
    account.memberships.first.update_attributes(role: Account::REVIEWER)
    assert account.reviewer?
    # Perhaps they're going back into business?
    account.upgrade_reviewer_to_real( organizations(:bankrupt), Account::ADMINISTRATOR )
    membership = account.memberships(true).first
    assert_equal organizations(:bankrupt), membership.organization
    assert_equal Account::ADMINISTRATOR, membership.role
  end

  it "has a canonical representation" do
    assert louis.canonical( :include_organization=>true, :include_document_counts=>true)
  end

  it "disallows leading/trailing spaces in email address" do
    account = Account.new(first_name: ' Bob', last_name: 'Smith ',
      language: DC::Language::DEFAULT, document_language: DC::Language::DEFAULT )
    account.email = ' bob@test.com'
    refute account.save
    assert account.errors.include?(:email)
    account.email = 'bob@test.com '
    refute account.save
    assert account.errors.include?(:email)
    account.email = 'bob@test.com'
    assert account.save
  end
end
