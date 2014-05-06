class FeaturedReport < ActiveRecord::Base

  validates :url, :title, :organization, :writeup, :presence=>true
  validate do | rec |
    rec.errors.add(:article_date, 'is invalid') if rec.article_date.blank?
  end

  scope :sorted, ->{ order('present_order asc, created_at desc') }

  before_save :fixup_url

  def fixup_url
    self.url = "http://#{url}" unless url=~/^http\:\/\//
  end

  def writeup=(markdown)
    super(markdown)
    @writeup_html = nil
  end

  def writeup_html
    @writeup_html ||= RDiscount.new( writeup ).to_html.html_safe
  end

  def serializable_hash( options={} )
    methods = { :methods=>[ :writeup_html ] }
    super( options ? options.merge(methods) : methods )
  end

end
