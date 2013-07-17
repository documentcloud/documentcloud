require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  EMAIL = 'lmercier@tribune.org'

  let (:louis) { Account.find_by_email(EMAIL) }
  let (:tribune) { organizations(:tribune) }

  it "should not be able to log in with a bad password" do
    account = Account.log_in(EMAIL, 'nope', {})
    refute account
  end

  it "has scopes and they work" do
    assert_includes Account.admin, louis
    assert_includes Account.active, louis
    assert_includes Account.real, louis
    refute_includes Account.reviewer, louis
  end

  it "should be able to log in" do
    session = {}
    account = Account.log_in(EMAIL, 'password', session, {})
    assert account
    assert account.email == EMAIL
    assert session['account_id'] == account.id
  end

  it "does generate computed attributes" do
    assert louis.full_name == "Louis Mercier"
    assert louis.rfc_email == "\"Louis Mercier\" <#{EMAIL}>"
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
    assert ActionMailer::Base.deliveries.empty?
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

  it "can have multiple identities" do
    ids = { 'facebook'=>'12' }
    louis.identities = ids
    assert louis.save
    louis.reload
    assert_kind_of Hash, louis.identities
    assert_equal ids, louis.identities
    assert_equal louis, Account.with_identity( 'facebook', 12 ).first
  end

  it "ensures only one account has identity" do
    ids = { 'facebook'=>'12' }
    louis.identities = ids
    assert louis.save
    acct = Account.new({ :identities=> ids })
    refute acct.save
    assert acct.errors.include?(:identities)
  end

  it "has a canonical representation" do
    assert louis.canonical( :include_organization=>true, :include_document_counts=>true)
  end

end
