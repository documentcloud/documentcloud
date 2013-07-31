class Docdata < ActiveRecord::Base

  belongs_to :document

  before_validation :convert_data_to_hash
  validates :document_id, :uniqueness=>{ :allow_nil => true }
  validate :ensure_keys_are_not_forbidden
  after_save :index_document

  # def self.to_hstore(hash)
  #   hash.map {|k, v| "\"#{sanitize(k)}\"=>\"#{sanitize(v)}\"" }.join(',')
  # end

  # def self.sanitize(obj)
  #   Sanitize.clean(obj.to_s.gsub(/[\\"]/, ''))
  # end

  # def data=(obj)
  #   @data = nil
  #   return self[:data] = obj if obj.is_a? String
  #   return unless validate_keys(obj)
  #   if obj.empty?
  #     self[:data] = nil
  #     self.destroy
  #   else
  #     self[:data] = Docdata.to_hstore(obj)
  #   end
  # end

  # def data
  #   @data ||= Hash[(self[:data] || "").scan(/"(.*?[^\\]|)"=>"(.*?[^\\]|)"/)]
  # end

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
