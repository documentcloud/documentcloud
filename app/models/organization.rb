class Organization < ActiveRecord::Base
    
  has_many :accounts, :dependent => :destroy
  
  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug
  validates_format_of :slug, :with => DC::Validators::SLUG
  
end
