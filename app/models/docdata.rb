class Docdata < ActiveRecord::Base

  belongs_to :document

  before_validation :convert_data_to_hash
  validates :document_id, :uniqueness=>{ :allow_nil => true }
  validate  :ensure_keys_are_not_forbidden
  validates :data, :presence=>true
  after_save :index_document

  private

  def convert_data_to_hash
    return if self.data.is_a?(Hash)
    if self.data.blank?
      self.data = {}
    else
      self.data = Hash[(self.data).scan(/"(.*?[^\\]|)"=>"(.*?[^\\]|)"/)]
    end
  end

  def ensure_keys_are_not_forbidden
    if forbidden = self.data.keys.detect {|key| DC::ALL_SEARCHES.include?(key.to_sym) }
      errors.add( :base, "Invalid data key: #{forbidden}" )
      false
    else
      true
    end
  end

  def index_document
    self.document.index
  end

end
