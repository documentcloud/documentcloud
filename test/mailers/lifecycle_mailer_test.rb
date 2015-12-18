require 'test_helper'

class LifecycleMailerTest < ActionMailer::TestCase

  def test_login_instructions
    email = LifecycleMailer.login_instructions(louis, louis.organization).deliver_now
    assert !ActionMailer::Base.deliveries.empty?
    assert_equal [ louis.email ], email.to
    @key=louis.security_key.key
    #assert_equal read_fixture('login_instructions'), email.body.to_s
  end

  def test_membership_notification
    email = LifecycleMailer.membership_notification( louis, organizations(:dcloud), accounts(:admin) ).deliver_now
    assert_equal [ louis.email ], email.to
    assert_equal read_fixture('membership_notification'), email.body.to_s
  end

  def test_reviewer_instructions
    email = LifecycleMailer.reviewer_instructions( [ secret_doc ], accounts(:admin),
                                                  joe, "Don't mess this up!", '1234' ).deliver_now
    assert_equal [ accounts(:admin).email ], email.cc
    assert_equal [ joe.email ], email.to
    assert_equal 'Review "Secret Plans" on DocumentCloud', email.subject
    assert_match( /Admin Person at The Daily Tribune has invited you to review "Secret Plans."/, email.body.to_s )
  end

  def test_reset_request
    email = LifecycleMailer.reset_request( louis )
    assert_equal [ louis.email ], email.to
    @key=louis.security_key.key
    assert_equal read_fixture('reset_request'), email.body.to_s
  end

  def test_contact_us
    email = LifecycleMailer.contact_us( louis, { :message=> "Greetings!", :email=>'test@test.com' } )
    assert_equal [ LifecycleMailer::NO_REPLY ], email.from
    assert_equal [ LifecycleMailer::SUPPORT ], email.to
    assert_equal [ louis.email ], email.reply_to
    assert_equal read_fixture('contact_us'), email.body.to_s
  end

  def test_exception_notification
    exception = nil
    begin
      jklasfa
    rescue Exception=>exception
    end
    email = LifecycleMailer.exception_notification(exception).deliver_now
    assert_equal [ LifecycleMailer::EXCEPTIONS ], email.to
    assert_match(/undefined local variable or method `jklasfa'/, email.body.to_s ) #`
  end

  def test_documents_finished_processing
    email = LifecycleMailer.documents_finished_processing(louis, 42).deliver_now
    assert_equal [ louis.email ], email.to
    assert_equal read_fixture('documents_finished_processing'), email.body.to_s
  end

  def test_account_and_document_csvs
    email = LifecycleMailer.account_and_document_csvs.deliver_now
    assert_equal [ LifecycleMailer::INFO ], email.to
    assert_equal 2,  email.attachments.length
  end

  def test_logging_email
    email = LifecycleMailer.logging_email('test',{
                                      :document_id => secret_doc.id
                                    }).deliver_now
    assert_match(/lifecycle_mailer_test.rb/, email.body.to_s )
    assert_match(/document_id: 190792297 \(Fixnum\)/, email.body.to_s )
  end

  # Email the owner of a document which is having difficulty processing
  def test_permission_to_review
    assert_difference ->{ActionMailer::Base.deliveries.count}, 1 do
      LifecycleMailer.permission_to_review(doc).deliver_now
    end
  end

end
