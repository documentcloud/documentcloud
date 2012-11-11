
class FeaturedReport < ActiveRecord::Base

  validates_presence_of :url, :title, :organization, :writeup
  validate do | rec |
    rec.errors.add(:article_date, 'is invalid') if rec.article_date.blank?
  end

  named_scope :sorted, :order=>'present_order asc, created_at desc' 
  
  before_save :fixup_url

  def fixup_url
    self.url = "http://#{url}" unless url=~/^http\:\/\//
  end

  def writeup=(markdown)
    super(markdown)
    @writeup_html = nil
  end

  def writeup_html
    @writeup_html ||= RDiscount.new( writeup ).to_html
  end


  def to_json(opts={})
    super( opts.merge(:methods=>[ :writeup_html ] ) )
  end

end
