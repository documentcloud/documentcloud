# A (News or Watchdog) organization with the power to create DocumentCloud
# accounts and upload documents.
class Organization < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  has_many :accounts, :dependent => :destroy

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug
  validates_format_of :slug, :with => DC::Validators::SLUG

  # How many documents have been uploaded across the whole organization?
  def document_count
    Document.count(:conditions => {:organization_id => id})
  end

  # The list of all administrator emails in the organization.
  def admin_emails
    self.accounts.admin.all(:select => [:email]).map &:email
  end

  # The list of all administrator email addresses, excluding mine.
  def other_admin_emails(account)
    admin_emails - [account.email]
  end

  def to_json(options = nil)
    {'name'           => name,
     'slug'           => slug,
     'id'             => id,
     'since'          => time_ago_in_words(created_at),
     'document_count' => document_count,
     'account_count'  => accounts.count}.to_json
  end

end
