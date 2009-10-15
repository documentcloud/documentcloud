class AppConstant < ActiveRecord::Base
  
  validates_presence_of :key
  validates_uniqueness_of :key
    
  def self.value(key, default=nil)
    result = find_by_key(key)
    result ? result.value : (default || nil)
  end
  
  def self.replace(key, new_value, default=nil)
    current = value(key)
    constant = find_or_initialize_by_key(key)
    constant.update_attribute(:value, new_value)
    current
  end
      
end