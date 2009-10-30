class Document < ActiveRecord::Base
  
  attr_accessor :rdf, :calais_signature

  has_one  :full_text,  :dependent => :destroy
  has_many :pages,      :dependent => :destroy  
  has_many :metadata,   :dependent => :destroy
  
end