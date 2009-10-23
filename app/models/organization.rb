class Organization < ActiveRecord::Base
    
  has_many :accounts, :dependent => :destroy
  
  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug
  validates_format_of :slug, :with => DC::Validators::SLUG
  
  def self.current
    Thread.current[:current_organization]
  end
  
  def self.current=(organization)
    Thread.current[:current_organization] = organization
  end
  
end
