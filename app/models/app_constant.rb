# Since we're off Sphinx, the AppConstant isn't being used at the moment.
class AppConstant < ActiveRecord::Base

  validates :key, :uniqueness=>true, :presence=>true

  def self.value(key, default=nil)
    result = find_by_key(key)
    result ? result.value : (default || nil)
  end

  def self.replace(key, new_value, default=nil)
    current = value(key)
    constant = AppConstant.where(key: key).first_or_initialize
    constant.update_attribute(:value, new_value)
    current
  end

end
