class Docdata < ActiveRecord::Base

  belongs_to :document

  before_validation :convert_data_to_hash
  validates :document_id, :uniqueness=>{ :allow_nil => true }
  validate  :ensure_keys_are_not_forbidden
  validates :data, :presence=>true
  after_save :index_document
  
  DEPTH_LIMIT = 1
  DATA_TYPES = [String, Numeric, FalseClass, TrueClass, NilClass]

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
  
  def ensure_depth_limit
    self.data.values.all? do |obj|
      case
        when DATA_TYPES.any?{ |klass| obj.kind_of? klass }
          true
        when obj.kind_of?(Array)
          obj.values.all?{ |item| DATA_TYPE.any?{ |klass| item.kind_of? klass } }
        when obj.kind_of?(Hash)
          obj.all?{ |key, value| DATA_TYPE.any?{ |klass| value.kind_of? klass } }
        else
          false
      end
    end
  end
  
  def index_document
    self.document.index
  end
end
