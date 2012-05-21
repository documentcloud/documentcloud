class Comment < ActiveRecord::Base
  include DC::Access
  
  belongs_to :annotation
  belongs_to :document
  belongs_to :commenter

  attr_accessor :author
  
  validates_presence_of :text
  
  def canonical(options = {})
    data           = {
      'text'          => text,
      'created_at'    => created_at
    }
    data.merge!({ 'author' => author }) if author
    data
  end

  def to_json(options={})
    canonical.to_json
  end
  
end
