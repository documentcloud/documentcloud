class Document < ActiveRecord::Base
  
  attr_accessor :rdf, :calais_signature

  has_one  :full_text,  :dependent => :destroy
  has_many :pages,      :dependent => :destroy  
  has_many :metadata,   :dependent => :destroy
  
  def to_json(opts={})
    attributes.to_json
  end
  
end