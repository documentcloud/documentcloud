# Searches can be saved to be run again later.
class SavedSearch < ActiveRecord::Base

  belongs_to :account
  validates_presence_of :account_id, :query
  validates_uniqueness_of :query, :scope => :account_id

  named_scope :alphabetical, {:order => 'query'}

  def to_json(opts={})
    attributes.to_json
  end

end