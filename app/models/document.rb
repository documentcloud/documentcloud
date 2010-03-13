class Document < ActiveRecord::Base
  include DC::Access

  attr_accessor :highlight, :annotation_count

  SEARCHABLE_ATTRIBUTES = [:title, :source, :documents, :notes, :contributor]

  DEFAULT_TITLE = "Untitled Document"

  has_one  :full_text,      :dependent => :destroy
  has_many :pages,          :dependent => :destroy
  has_many :metadata,       :dependent => :destroy
  has_many :metadata_dates, :dependent => :destroy
  has_many :sections,       :dependent => :destroy
  has_many :annotations,    :dependent => :destroy

  has_many :project_memberships, :dependent => :destroy

  validates_presence_of :organization_id, :account_id, :access, :page_count,
                        :title, :slug

  before_validation_on_create :ensure_titled

  after_destroy :delete_assets

  delegate :text, :to => :full_text, :allow_nil => true

  named_scope :chronological, {:order => 'created_at desc'}

  named_scope :owned_by, lambda { |account|
    {:conditions => {:account_id => account.id}}
  }

  named_scope :pending, :conditions => {:access => PENDING}

  # Restrict accessible documents for a given account/organzation.
  named_scope :accessible, lambda { |account, org|
    access = []
    access << "(documents.access = #{PUBLIC})"
    access << "(documents.access in (#{PRIVATE}, #{PENDING}) and documents.account_id = #{account.id})" if account
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

  def public?
    self.access == PUBLIC
  end

  # When the access level changes, all sub-resource and asset permissions
  # need to be updated.
  def set_access(access_level)
    update_attributes(:access => access_level)
    sql = ["access = #{access_level}", "document_id = #{id}"]
    FullText.update_all(*sql)
    Page.update_all(*sql)
    Metadatum.update_all(*sql)
    MetadataDate.update_all(*sql)
    background_update_asset_access
  end

  # If we need to change the ownership of the document, we have to propagate
  # the change to all associated models.
  def set_owner(account)
    org = account.organization
    update_attributes(:account_id => account.id, :organization_id => org.id)
    sql = ["account_id = #{account.id}, organization_id = #{org.id}", "document_id = #{id}"]
    FullText.update_all(*sql)
    Page.update_all(*sql)
    Metadatum.update_all(*sql)
    MetadataDate.update_all(*sql)
  end

  # Ex: docs/1011
  def path
    File.join('documents', id.to_s)
  end

  # Ex: docs/1011/sec-madoff-investigation.txt
  def full_text_path
    File.join(path, slug + '.txt')
  end

  # Ex: docs/1011/sec-madoff-investigation.pdf
  def pdf_path
    File.join(path, slug + '.pdf')
  end

  # Ex: docs/1011/sec-madoff-investigation.rdf
  def rdf_path
    File.join(path, slug + '.rdf')
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

  def public_pdf_url
    File.join(DC::Store::AssetStore.web_root, pdf_path)
  end

  def private_pdf_url
    File.join(DC_CONFIG['server_root'], pdf_path)
  end

  def pdf_url(direct=false)
    return public_pdf_url  if public? || Rails.env.development?
    return private_pdf_url unless direct
    DC::Store::AssetStore.new.authorized_url(pdf_path)
  end

  def public_thumbnail_url
    File.join(DC::Store::AssetStore.web_root, page_image_path(1, 'thumbnail'))
  end

  def private_thumbail_url
    DC::Store::AssetStore.new.authorized_url(page_image_path(1, 'thumbnail'))
  end

  def thumbnail_url
    public? ? public_thumbnail_url : private_thumbail_url
  end

  def public_full_text_url
    File.join(DC::Store::AssetStore.web_root, full_text_path)
  end

  def private_full_text_url
    File.join(DC_CONFIG['server_root'], full_text_path)
  end

  def full_text_url
    public? ? public_full_text_url : private_full_text_url
  end

  def document_viewer_url(opts={})
    suffix = ''
    suffix = "#document/p#{opts[:page]}" if opts[:page]
    if ent = opts[:entity]
      occur = ent.split_occurrences.first
      if DC_CONFIG['entities_via_search']
        suffix = "#search/p#{occur.page.page_number}/#{URI.escape(ent.value)}"
      else
        suffix = "#entity/p#{occur.page.page_number}/#{URI.escape(ent.value)}/#{occur.page_offset}:#{occur.length}"
      end
    end
    if date = opts[:date]
      occur = date.split_occurrences.first
      suffix = "#entity/p#{occur.page.page_number}/#{URI.escape(date.date.to_s)}/#{occur.page_offset}:#{occur.length}"
    end
    "#{DC_CONFIG['server_root']}/documents/#{id}-#{slug}.html#{suffix}"
  end

  def search_url
    "#{DC_CONFIG['server_root']}/documents/#{id}/search.json?q={query}"
  end

  def page_image_path(page_number, size)
    File.join(pages_path, "#{slug}-p#{page_number}-#{size}.gif")
  end

  def page_text_path(page_number)
    File.join(pages_path, "#{slug}-p#{page_number}.txt")
  end

  def public_page_image_template
    File.join(DC::Store::AssetStore.web_root, page_image_template)
  end

  def private_page_image_template
    File.join(DC_CONFIG['server_root'], page_image_template)
  end

  def page_image_url_template
    public? || Rails.env.development? ? public_page_image_template : private_page_image_template
  end

  def page_text_url_template
    File.join(DC_CONFIG['server_root'], page_text_template)
  end

  def asset_store
    @asset_store ||= DC::Store::AssetStore.new
  end

  def delete_assets
    asset_store.destroy(self)
  end

  def queue_initial_import(eventual_access=PRIVATE)
    job = JSON.parse(DC::Import::CloudCrowdImporter.new.import([id], {
      'id'            => id,
      'access'        => eventual_access
    }))
    ProcessingJob.create!(
      :account_id     => account_id,
      :cloud_crowd_id => job['id'],
      :title          => title,
      :remote_job     => job
    )
  end

  # TODO: Make the to_json an extended form of the canonical.
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
      'description'         => description,
      'highlight'           => highlight,
      'annotation_count'    => annotation_count,
      'pdf_url'             => pdf_url,
      'thumbnail_url'       => thumbnail_url,
      'full_text_url'       => full_text_url,
      'page_image_url'      => page_image_url_template,
      'document_viewer_url' => document_viewer_url,
      'remote_url'          => remote_url
    }.to_json
  end

  def canonical(options={})
    doc = ActiveSupport::OrderedHash.new
    doc['id']          = "#{id}-#{slug}"
    doc['title']       = title
    doc['pages']       = page_count
    doc['description'] = description
    doc['resources']   = res = ActiveSupport::OrderedHash.new
    res['pdf']         = pdf_url
    res['text']        = full_text_url
    res['thumbnail']   = thumbnail_url
    res['search']      = search_url
    res['page']        = {'image' => page_image_url_template, 'text' => page_text_url_template}
    doc['sections']    = sections.map(&:canonical)
    doc['annotations'] = annotations.accessible(options[:account]).map(&:canonical)
    doc['entities']    = metadata.map(&:canonical) if options[:show_entities]
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

  def background_update_asset_access
    return true if Rails.env.development?
    RestClient.post(DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      'action'  => 'update_access',
      'inputs'  => [self.id],
      'callback_url' => "#{DC_CONFIG['server_root']}/import/update_access"
    }.to_json})
  end

end