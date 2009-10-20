class SavedSearch < ActiveRecord::Base
  
  belongs_to :account
  validates_presence_of :account_id, :query
  validates_uniqueness_of :query, :scope => :account_id
  
  def as_json(opts={})
    attributes
  end
  
end