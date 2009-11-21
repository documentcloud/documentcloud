class Organization < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  has_many :accounts, :dependent => :destroy

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug
  validates_format_of :slug, :with => DC::Validators::SLUG

  def document_count
    Document.count(:conditions => {:organization_id => id})
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
