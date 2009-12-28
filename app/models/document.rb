class Document < ActiveRecord::Base
  include DC::Access

  attr_accessor :highlight

  SEARCHABLE_ATTRIBUTES = [:title, :source, :account]

  DEFAULT_TITLE = "Untitled Document"

  has_one  :full_text,    :dependent => :destroy
  has_many :pages,        :dependent => :destroy
  has_many :metadata,     :dependent => :destroy
  has_many :sections,     :dependent => :destroy
  has_many :annotations,  :dependent => :destroy

  validates_presence_of :organization_id, :account_id, :access, :page_count,
                        :title, :slug

  before_validation_on_create :ensure_titled

  after_destroy :delete_assets

  delegate :text, :to => :full_text

  named_scope :chronological, {:order => 'created_at desc'}

  # Restrict accessible documents for a given account/organzation.
  named_scope :accessible, lambda { |account, org|
    access = []
    access << "(documents.access = #{PUBLIC})"
    access << "(documents.access = #{PRIVATE} and documents.account_id = #{account.id})" if account
    access << "(documents.access in (#{ORGANIZATION}, #{EXCLUSIVE}) and documents.organization_id = #{org.id})" if org
    {:conditions => "(#{access.join(' or ')})"}
  }

  # Main document search method -- handles queries.
  def self.search(query, options={})
    query = DC::Search::Parser.new.parse(query) if query.is_a? String
    query.run(options)
  end

  # Produce the full text of the document by combining the text of each of
  # the pages. Used at initial import.
  def combined_page_text
    self.pages.all(:select => [:text]).map(&:text).join('')
  end

  # Does this document have a title?
  def titled?
    title.present? && (title != DEFAULT_TITLE)
  end

  # Ex: docs/1011
  def path
    File.join('docs', id.to_s)
  end

  # Ex: docs/1011/sec-madoff-investigation.txt
  def full_text_path
    File.join(path, slug + '.txt')
  end

  # Ex: docs/1011/sec-madoff-investigation.pdf
  def pdf_path
    File.join(path, slug + '.pdf')
  end

  # Ex: docs/1011/sec-madoff-investigation.jpg
  def thumbnail_path
    File.join(path, slug + '.jpg')
  end

  # Ex: docs/1011/pages
  def pages_path
    File.join(path, 'pages')
  end

  def page_image_template
    File.join(pages_path, "#{slug}-p{page}-{size}.gif")
  end

  def page_text_template
    File.join(pages_path, "#{slug}-p{page}.txt")
  end

  def public?
    self.access == PUBLIC
  end

  def pdf_url
    File.join(DC::Store::AssetStore.web_root, pdf_path)
  end

  def thumbnail_url
    File.join(DC::Store::AssetStore.web_root, thumbnail_path)
  end

  def full_text_url
    File.join(DC::Store::AssetStore.web_root, full_text_path)
  end

  def document_viewer_url
    "#{DC_CONFIG['server_root']}/documents/#{id}-#{slug}.html"
  end

  def search_url
    "#{DC_CONFIG['server_root']}/documents/#{id}/search.json?q={query}"
  end

  def page_image_url_template
    File.join(DC::Store::AssetStore.web_root, page_image_template)
  end

  def page_text_url_template
    "#{DC_CONFIG['server_root']}/documents/#{id}/#{slug}-p{page}.txt"
  end

  def asset_store
    @asset_store ||= DC::Store::AssetStore.new
  end

  def save_assets(assets)
    asset_store.save(self, assets)
  end

  def delete_assets
    asset_store.destroy(self)
  end

  def to_json(options={})
    {
      'id'                  => id,
      'organization_id'     => organization_id,
      'account_id'          => account_id,
      'access'              => access,
      'page_count'          => page_count,
      'title'               => title,
      'slug'                => slug,
      'source'              => source,
      'summary'             => summary,
      'highlight'           => highlight,
      'pdf_url'             => pdf_url,
      'thumbnail_url'       => thumbnail_url,
      'full_text_url'       => full_text_url,
      'document_viewer_url' => document_viewer_url,
    }.to_json
  end

  def canonical(account=nil)
    doc = ActiveSupport::OrderedHash.new
    doc['id']          = "#{id}-#{slug}"
    doc['title']       = title
    doc['pages']       = page_count
    doc['resources']   = res = ActiveSupport::OrderedHash.new
    res['pdf']         = pdf_url
    res['text']        = full_text_url
    res['thumbnail']   = thumbnail_url
    res['search']      = search_url
    res['page']        = {'image' => page_image_url_template, 'text' => page_text_url_template}
    doc['sections']    = sections.map(&:canonical)
    doc['annotations'] = annotations.accessible(account).map(&:canonical)
    doc
  end


  private

  def ensure_titled
    self.title ||= DEFAULT_TITLE
    return true if self.slug
    slugged = title.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n, '').to_s # As ASCII
    slugged.gsub!(/[']+/, '') # Remove all apostrophes.
    slugged.gsub!(/\W+/, ' ') # All non-word characters become spaces.
    slugged.strip!            # strip surrounding whitespace
    slugged.downcase!         # ensure lowercase
    slugged.gsub!(' ', '-')   # dasherize spaces
    self.slug = slugged
  end

end