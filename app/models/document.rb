class Document < ActiveRecord::Base
  include DC::Access
  include ActionView::Helpers::TextHelper

  # Accessors and constants:

  attr_accessor :mentions, :total_mentions, :annotation_count, :hits
  attr_writer   :organization_name, :organization_slug, :account_name, :account_slug

  DEFAULT_TITLE = "Untitled Document"

  MINIMUM_POPULAR = 100

  CONCURRENT_UPLOAD_LIMIT = 10

  DISPLAY_DATE_FORMAT     = "%b %d, %Y"
  DISPLAY_DATETIME_FORMAT = "%I:%M %p – %a %b %d, %Y"

  DEFAULT_CANONICAL_OPTIONS = {
    :sections => true, :annotations => true, :contributor => true
  }

  DEFAULT_IMPORT_OPTIONS = {
    :access => nil, :text_only => false, :email_me => false, :force_ocr => false, :secure => false
  }

  # If the Document.pending count is greater than this number, send a warning.
  WARN_QUEUE_LENGTH = 50

  # DB Associations:

  belongs_to :account
  belongs_to :organization

  has_one  :docdata,              :dependent   => :destroy
  has_many :pages,                :dependent   => :destroy
  has_many :entities,             :dependent   => :destroy
  has_many :entity_dates,         :dependent   => :destroy
  has_many :sections,             :dependent   => :destroy
  has_many :annotations,          :dependent   => :destroy
  has_many :remote_urls,          :dependent   => :destroy
  has_many :project_memberships,  :dependent   => :destroy
  has_many :projects,             :through     => :project_memberships
  has_one  :reviewer_project,     :through     => :project_memberships,
                                  :conditions  => {:hidden => true},
                                  :source      => :project

  validates_presence_of :organization_id, :account_id, :access, :page_count,
                        :title, :slug

  before_validation_on_create :ensure_titled

  after_destroy :delete_assets

  # Sanitizations (title handled separately):
  text_attr :source, :related_article, :remote_url
  html_attr :description

  delegate :slug, :to => :organization, :allow_nil => true, :prefix => true
  delegate :slug, :to => :account,      :allow_nil => true, :prefix => true

  # Named scopes:

  named_scope :chronological, {:order => 'created_at desc'}

  # NB: This is *not* efficient.
  named_scope :random,        {:order => 'random()'}

  named_scope :owned_by, lambda { |account|
    {:conditions => {:account_id => account.id}}
  }

  named_scope :published,     :conditions => 'remote_url is not null or detected_remote_url is not null'
  named_scope :unpublished,   :conditions => 'remote_url is null and detected_remote_url is null'

  named_scope :pending,       :conditions => {:access => PENDING}
  named_scope :failed,        :conditions => {:access => ERROR}
  named_scope :unrestricted,  :conditions => {:access => PUBLIC}
  named_scope :restricted,    :conditions => {:access => [PRIVATE, ORGANIZATION]}
  named_scope :finished,      :conditions => {:access => [PUBLIC, PRIVATE, ORGANIZATION]}

  named_scope :popular,       :conditions => ["hit_count > ?", MINIMUM_POPULAR]

  named_scope :due, lambda {|time|
    {:conditions => ["publish_at <= ?", Time.now.utc]}
  }

  named_scope :since, lambda {|time|
    time ? {:conditions => ["created_at >= ?", time]} : {}
  }

  # Restrict accessible documents for a given account/organization.
  # Either the document itself is public, or it belongs to us, or it belongs to
  # our organization and we're allowed to see it, or it belongs to a project
  # that's been shared with us.
  named_scope :accessible, lambda {|account, org|
    has_shared = account && account.accessible_project_ids.present?
    access = []
    access << "(documents.access = #{PUBLIC})"
    access << "(documents.access in (#{PRIVATE}, #{PENDING}, #{ERROR}, #{ORGANIZATION}, #{EXCLUSIVE}) and documents.account_id = #{account.id})" if account
    access << "(documents.access in (#{ORGANIZATION}, #{EXCLUSIVE}) and documents.organization_id = #{org.id})" if org && account && !account.freelancer?
    access << "(memberships.document_id = documents.id)" if has_shared
    opts = {:conditions => ["(#{access.join(' or ')})"], :readonly => false}
    if has_shared
      opts[:joins] = <<-EOS
        left outer join 
        (select distinct document_id from project_memberships 
          where project_id in (#{account.accessible_project_ids.join(',')})) as memberships
        on memberships.document_id = documents.id
      EOS
    end
    opts
  }

  # The definition of the Solr search index. Via sunspot-rails.
  searchable do

    # Full Text...
    text :title, :default_boost => 2.0
    text :source
    text :description
    text :full_text, {:more_like_this => true} do
      self.combined_page_text
    end

    # Attributes...
    string  :title
    string  :source
    time    :created_at
    boolean :published, :using => :published?
    integer :id
    integer :account_id
    integer :organization_id
    integer :access
    integer :page_count
    integer :hit_count
    integer :public_note_count
    integer :project_ids, :multiple => true do
      self.project_memberships.map {|m| m.project_id }
    end

    # Entities...
    DC::ENTITY_KINDS.each do |entity|
      text(entity) { self.entity_values(entity) }
      string(entity, :multiple => true) { self.entity_values(entity) }
    end
    
    # Data...
    dynamic_string :data do
      self.docdata ? self.docdata.data.symbolize_keys : {}
    end

  end

  # Main document search method -- handles queries.
  def self.search(query, options={})
    query = DC::Search::Parser.new.parse(query) if query.is_a? String
    query.run(options)
  end

  # Upload a new document, starting the import process.
  def self.upload(params, account, organization)
    name     = params[:url] || params[:file].original_filename
    title    = params[:title] || File.basename(name, File.extname(name)).titleize
    access   = params[:make_public] ? PUBLIC :
               (params[:access] ? ACCESS_MAP[params[:access].to_sym] : PRIVATE)
    email_me = params[:email_me] ? params[:email_me].to_i : false
    doc = self.create!(
      :organization_id  => organization.id,
      :account_id       => account.id,
      :access           => PENDING,
      :page_count       => 0,
      :title            => title,
      :description      => params[:description],
      :source           => params[:source],
      :related_article  => params[:related_article],
      :remote_url       => params[:published_url] || params[:remote_url]
    )
    import_options = {:access => access, :email_me => email_me, :secure => params[:secure]}
    if params[:url]
      doc.queue_import import_options.merge(:url => params[:url])
    else
      DC::Import::PDFWrangler.new.ensure_pdf(params[:file], params[:Filename]) do |path|
        DC::Store::AssetStore.new.save_pdf(doc, path, access)
        doc.queue_import import_options
      end
    end
    if params[:project]
      project = Project.accessible(account).find_by_id(params[:project].to_i)
      project.add_document(doc) if project
    end
    if params[:data]
      doc.data = params[:data]
    end
    doc.reload
  end

  # Insert all documents that have been previously saved into the document's
  # `/inserts` folder in the asset store.
  def insert_documents(insert_page_at, document_count, eventual_access=nil)
    eventual_access ||= self.access || PRIVATE
    self.update_attributes :access => PENDING
    record_job(RestClient.post(DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      'action'  => 'document_insert_pages',
      'inputs'  => [id],
      'options' => {
        :id              => id,
        :insert_page_at  => insert_page_at,
        :pdfs_count      => document_count,
        :access          => eventual_access
      }
    }.to_json}).body)
  end

  # Publish all documents with a `publish_at` timestamp that is past due.
  def self.publish_due_documents
    Document.restricted.due.find_each {|doc| doc.set_access PUBLIC }
  end

  # Populate the annotation counts for a list of documents with a single SQL.
  def self.populate_annotation_counts(account, docs)
    counts = Annotation.counts_for_documents(account, docs)
    docs.each {|doc| doc.annotation_count = counts[doc.id] }
  end

  # Ensure that titles are stripped of trailing whitespace.
  def title=(title="Untitled Document")
    self[:title] = self.strip title.strip
  end

  # Save all text assets, including the `combined_page_text`, and the text of
  # each page individually, to the asset store.
  def upload_text_assets(pages, access)
    asset_store.save_full_text(self, access)
    pages.each do |page|
      asset_store.save_page_text(self, page.page_number, page.text, access)
    end
  end

  # Update a document, with S3 permission fixing, cache expiry, and access control.
  def secure_update(attrs, account)
    if !account.allowed_to_edit?(self)
      self.errors.add_to_base "You don't have permission to update the document."
      return false
    end
    access = attrs.delete :access
    access &&= access.to_i
    published_url = attrs.delete :published_url
    attrs[:remote_url] ||= published_url
    data = attrs.delete :data
    update_attributes attrs
    self.data = data if data
    set_access(access) if access && self.access != access
    true
  end

  # For polymorphism on access control with Note and Section:
  def document_id
    id
  end

  # Produce the full text of the document by combining the text of each of
  # the pages. Used at initial import.
  def combined_page_text
    self.pages.all(:select => [:text], :order => 'page_number asc').map(&:text).join('')
  end

  # Determine the number of annotations on each page of this document.
  def per_page_annotation_counts
    self.annotations.count(:group => 'page_number')
  end

  def annotations_with_authors(account, annotations=nil)
    annotations ||= self.annotations.accessible(account)
    Annotation.populate_author_info(annotations, account)
    annotations
  end

  # Return an array of all of the document entity values for a given type,
  # for Solr indexing purposes.
  def entity_values(kind)
    self.entities.kind(kind.to_s).all(:select => [:value]).map {|e| e.value }
  end

  # Reset the cached counter of public notes on the document.
  def reset_public_note_count
    count = annotations.unrestricted.count
    if count != self.public_note_count
      update_attributes :public_note_count => count
    end
  end

  # Return a hash of all the document's entities (for an API response).
  # The hash is ordered by entity kind, after the sidebar, with individual
  # entities sorted by relevance.
  def ordered_entity_hash
    hash = ActiveSupport::OrderedHash.new
    DC::VALID_KINDS.each {|kind| hash[kind] = [] }
    entities.each do |e|
      hash[e.kind].push :value => e.value, :relevance => e.relevance
    end
    hash.each do |key, list|
      hash[key] = list.sort_by {|e| -e[:relevance] }
    end
    hash
  end

  # Does this document have a title?
  def titled?
    title.present? && (title != DEFAULT_TITLE)
  end

  def public?
    self.access == PUBLIC
  end

  def publicly_accessible?
    [PUBLIC, EXCLUSIVE].include? access
  end
  alias_method :cacheable?, :publicly_accessible?

  def published?
    publicly_accessible? && (remote_url.present? || detected_remote_url.present?)
  end

  def published_url
    remote_url || detected_remote_url
  end

  # When the access level changes, all sub-resource and asset permissions
  # need to be updated.
  def set_access(access_level)
    changes = {:access => PENDING}
    changes[:publish_at] = nil if access_level == PUBLIC
    update_attributes changes
    background_update_asset_access access_level
  end

  # If we need to change the ownership of the document, we have to propagate
  # the change to all associated models.
  def set_owner(account)
    org = account.organization
    update_attributes(:account_id => account.id, :organization_id => org.id)
    sql = ["account_id = #{account.id}, organization_id = #{org.id}", "document_id = #{id}"]
    Page.update_all(*sql)
    Entity.update_all(*sql)
    EntityDate.update_all(*sql)
  end

  def organization_name
    @organization_name ||= organization.name
  end

  def account_name
    @account_name ||= (account ? account.full_name : 'Unattributed')
  end
  
  def data
    docdata ? docdata.data : {}
  end
  
  def data=(hash)
    self.docdata = Docdata.create(:document_id => id) unless self.docdata
    docdata.update_attributes :data => hash
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

  def canonical_id
    "#{id}-#{slug}"
  end

  def canonical_path(format = :json)
    "documents/#{canonical_id}.#{format}"
  end

  def canonical_cache_path
    "/#{canonical_path(:js)}"
  end

  def project_ids
    self.project_memberships.map {|m| m.project_id }
  end
  
  # Externally used image path, not to be confused with `page_image_path()`
  def page_image_template
    "#{slug}-p{page}-{size}.gif"
  end

  def page_text_template
    "#{slug}-p{page}.txt"
  end

  def public_pdf_url
    File.join(DC::Store::AssetStore.web_root, pdf_path)
  end

  def private_pdf_url
    File.join(DC.server_root, pdf_path)
  end

  def pdf_url(direct=false)
    return public_pdf_url  if public? || Rails.env.development?
    return private_pdf_url unless direct
    DC::Store::AssetStore.new.authorized_url(pdf_path)
  end

  def thumbnail_url
    page_image_url 1, 'thumbnail'
  end

  def page_image_url(page, size)
    path = page_image_path(page, size)
    if public?
      File.join DC::Store::AssetStore.web_root, path
    else
      DC::Store::AssetStore.new.authorized_url path
    end
  end

  def public_full_text_url
    File.join(DC::Store::AssetStore.web_root, full_text_path)
  end

  def private_full_text_url
    File.join(DC.server_root, full_text_path)
  end

  def full_text_url(direct=false)
    return public_full_text_url if public? || Rails.env.development?
    return private_full_text_url unless direct
    DC::Store::AssetStore.new.authorized_url(full_text_path)
  end

  def document_viewer_url(opts={})
    suffix = ''
    suffix = "#document/p#{opts[:page]}" if opts[:page]
    if ent = opts[:entity]
      page  = self.pages.first(:conditions => {:page_number => opts[:page]})
      occur = ent.split_occurrences.detect {|o| o.offset == opts[:offset].to_i }
      suffix = "#entity/p#{page.page_number}/#{URI.escape(ent.value)}/#{occur.page_offset}:#{occur.length}"
    end
    if date = opts[:date]
      occur = date.split_occurrences.first
      suffix = "#entity/p#{occur.page.page_number}/#{URI.escape(date.date.to_s)}/#{occur.page_offset}:#{occur.length}" if occur.page
    end
    canonical_url(:html, opts[:allow_ssl]) + suffix
  end

  def canonical_url(format = :json, allow_ssl = false)
    File.join(DC.server_root(:ssl => allow_ssl), canonical_path(format))
  end

  def search_url
    "#{DC.server_root}/documents/#{id}/search.json?q={query}"
  end
  
  def print_annotations_url
    "#{DC.server_root}/notes/print?docs[]=#{id}"
  end

  # Internally used image path, not to be confused with page_image_template()
  def page_image_path(page_number, size)
    File.join(pages_path, "#{slug}-p#{page_number}-#{size}.gif")
  end

  def page_text_path(page_number)
    File.join(pages_path, "#{slug}-p#{page_number}.txt")
  end

  def public_page_image_template
    File.join(DC::Store::AssetStore.web_root, File.join(pages_path, page_image_template))
  end

  def private_page_image_template
    File.join(DC.server_root, File.join(pages_path, page_image_template))
  end

  def page_image_url_template(opts={})
    return File.join(slug, page_image_template) if opts[:local]
    public? || Rails.env.development? ? public_page_image_template : private_page_image_template
  end

  def page_text_url_template(opts={})
    return File.join(slug, page_text_template) if opts[:local]
    File.join(DC.server_root, File.join(pages_path, page_text_template))
  end

  def reviewers
    return [] unless reviewer_project
    reviewer_project.collaborators
  end

  def add_reviewer(account, creator)
    unless project = reviewer_project
      project = Project.create :hidden => true
      project.set_documents([id])
    end
    project.add_collaborator account, creator
  end

  def remove_reviewer(account)
    reviewer_project.remove_collaborator(account)
  end

  def reviewer_inviter(reviewer_account)
    collab = Collaboration.first(:conditions => [
      "account_id = ? AND project_id = ? AND creator_id IS NOT NULL",
      reviewer_account.id,
      reviewer_project.id
    ])
    collab && collab.creator
  end

  def low_priority?
    large  = self.file_size > 1.megabyte
    greedy = Document.owned_by(account).pending.count >= CONCURRENT_UPLOAD_LIMIT
    large || greedy
  end

  def asset_store
    @asset_store ||= DC::Store::AssetStore.new
  end

  def delete_assets
    asset_store.destroy(self)
  end

  def reprocess_text(force_ocr = false)
    queue_import :text_only => true, :force_ocr => force_ocr, :secure => !calais_id
  end
  
  def reprocess_images
    queue_import :images_only => true, :secure => !calais_id
  end

  def reindex_all!(access=nil)
    Page.refresh_page_map(self)
    EntityDate.reset(self)
    pages = self.reload.pages
    Sunspot.index pages
    reprocess_entities if calais_id
    upload_text_assets(pages, access)
    self.access = access if access
    self.save!
  end

  def reprocess_entities
    RestClient.post(DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      'action'  => 'reprocess_entities',
      'inputs'  => [id]
    }.to_json})
  end

  # Keep a local ProcessingJob record of this active CloudCrowd Job.
  def record_job(job_json)
    job = JSON.parse(job_json)
    ProcessingJob.create!(
      :document_id    => id,
      :account_id     => account_id,
      :cloud_crowd_id => job['id'],
      :title          => title,
      :remote_job     => job
    )
  end

  def save_page_text(modified_pages)
    eventual_access = self.access || PRIVATE
    self.update_attributes(
      :access       => PENDING,
      :text_changed => true
    )
    modified_pages.each_pair do |page_number, page_text|
      page = Page.find_by_document_id_and_page_number(id, page_number)
      page.text = page_text
      page.save
    end
    record_job(RestClient.post(DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      'action'  => 'reindex_document',
      'inputs'  => [id],
      'options' => {
        :id      => id,
        :access  => eventual_access
      }
    }.to_json}).body)
  end

  # Redactions is an array of objects: {'page' => 1, 'location' => '30,50,50,10'}
  def redact_pages(redactions)
    eventual_access = access || PRIVATE
    update_attributes :access => PENDING
    record_job(RestClient.post(DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      'action'  => 'redact_pages',
      'inputs'  => [id],
      'options' => {
        :id => id,
        :redactions => redactions,
        :access => eventual_access
      }
    }.to_json}).body)
  end

  def remove_pages(pages, replace_pages_start=nil, insert_document_count=nil)
    eventual_access = access || PRIVATE
    update_attributes :access => PENDING
    record_job(RestClient.post(DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      'action'  => 'document_remove_pages',
      'inputs'  => [id],
      'options' => {
        :id                    => id,
        :pages                 => pages,
        :access                => eventual_access,
        :replace_pages_start   => replace_pages_start,
        :insert_document_count => insert_document_count
      }
    }.to_json}).body)
  end

  def reorder_pages(page_order, eventual_access=nil)
    eventual_access ||= access || PRIVATE
    update_attributes :access => PENDING
    record_job(RestClient.post(DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      'action'  => 'document_reorder_pages',
      'inputs'  => [id],
      'options' => {
        :id          => id,
        :page_order  => page_order,
        :access      => eventual_access
      }
    }.to_json}).body)
  end

  def assert_page_order(page_order)
    same_size = page_order.uniq.length == self.page_count
    same_max  = page_order.max == self.page_count
    same_min  = page_order.min == 1
    same_size && same_max && same_min
  end

  def queue_import(opts={})
    options = DEFAULT_IMPORT_OPTIONS.merge opts
    options[:access] ||= self.access || PRIVATE
    options[:id] = id
    self.update_attributes :access => PENDING
    record_job(DC::Import::CloudCrowdImporter.new.import([id], options, self.low_priority?).body)
  end
  
  def self.duplicate(document_ids, account, options={})
    RestClient.post(DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      'action'  => 'duplicate_documents',
      'inputs'  => [document_ids],
      'options' => options.merge(
        :account_id => account.id
      )
    }.to_json})
  end
  
  # Create an identical clone of this document, in all ways (except for the ID).
  def duplicate!(account=nil, options={})
    # Clone the document.
    newattrs = attributes.merge({
      :access     => PENDING, 
      :created_at => Time.now, 
      :updated_at => Time.now
    })
    newattrs[:account_id] = account.id if account
    copy     = Document.create!(newattrs.merge({:hit_count  => 0, :detected_remote_url => nil}))
    newattrs = {:document_id => copy.id}
    
    # Clone the docdata.
    if docdata and options['include_docdata']
      Docdata.create! docdata.attributes.merge newattrs
    end
    
    # Clone the associations.
    associations = [entities, entity_dates, pages]
    associations.push sections if options['include_sections']
    associations.push annotations.accessible(account) if options['include_annotations']
    associations.push project_memberships if options['include_project']
    associations.each do |association|
      association.each do |model|
        model.class.create! model.attributes.merge newattrs
      end
    end
    
    # Clone the assets.
    DC::Store::AssetStore.new.copy_assets(self, copy)
    
    # Reindex, set access.
    copy.index
    copy.set_access access
    
    copy
  end

  # TODO: Make the to_json an extended form of the canonical.
  def to_json(opts={})
    json = {
      :id                  => id,
      :organization_id     => organization_id,
      :account_id          => account_id,
      :created_at          => created_at.to_date.strftime(DISPLAY_DATE_FORMAT),
      :access              => access,
      :page_count          => page_count,
      :annotation_count    => annotation_count || 0,
      :public_note_count   => public_note_count,
      :title               => title,
      :slug                => slug,
      :source              => source,
      :description         => description,
      :organization_name   => organization_name,
      :organization_slug   => organization_slug,
      :account_name        => account_name,
      :account_slug        => account_slug,
      :related_article     => related_article,
      :pdf_url             => pdf_url,
      :thumbnail_url       => thumbnail_url,
      :full_text_url       => full_text_url,
      :page_image_url      => page_image_url_template,
      :document_viewer_url => document_viewer_url,
      :document_viewer_js  => canonical_url(:js),
      :reviewer_count      => reviewer_count,
      :remote_url          => remote_url,
      :detected_remote_url => detected_remote_url,
      :publish_at          => publish_at.as_json,
      :hits                => hits,
      :mentions            => mentions,
      :total_mentions      => total_mentions,
      :project_ids         => project_ids,
      :data                => data
    }
    if opts[:annotations]
      json[:annotations] = self.annotations_with_authors(opts[:account])
    end
    json.to_json
  end

  # The filtered attributes we're allowed to display in the admin UI.
  def admin_attributes
    {
      :id                  => id,
      :account_name        => account_name,
      :organization_name   => organization_name,
      :page_count          => page_count,
      :thumbnail_url       => thumbnail_url,
      :pdf_url             => pdf_url(:direct),
      :public              => public?,
      :title               => public? ? title : nil,
      :source              => public? ? source : nil,
      :created_at          => created_at.to_datetime.strftime(DISPLAY_DATETIME_FORMAT),
      :remote_url          => remote_url,
      :detected_remote_url => detected_remote_url
    }
  end

  def canonical(options={})
    options = DEFAULT_CANONICAL_OPTIONS.merge(options)
    doc = ActiveSupport::OrderedHash.new
    doc['id']                 = canonical_id
    doc['title']              = title
    doc['access']             = ACCESS_NAMES[access] if options[:access]
    doc['pages']              = page_count
    doc['description']        = description
    doc['source']             = source
    doc['created_at']         = created_at.to_formatted_s(:rfc822)
    doc['updated_at']         = updated_at.to_formatted_s(:rfc822)
    doc['canonical_url']      = canonical_url(:html, options[:allow_ssl])
    if options[:contributor]
      doc['contributor']      = account_name
      doc['contributor_organization'] = organization_name
    end
    doc['resources']          = res = ActiveSupport::OrderedHash.new
    res['pdf']                = pdf_url
    res['text']               = full_text_url
    res['thumbnail']          = thumbnail_url
    res['search']             = search_url
    res['print_annotations']  = print_annotations_url
    res['page']               = {}
    res['page']['image']      = page_image_url_template(:local => options[:local])
    res['page']['text']       = page_text_url_template(:local => options[:local])
    res['related_article']    = related_article if related_article
    if options[:allow_detected]
      res['published_url']    = published_url if published_url
    else
      res['published_url']    = remote_url if remote_url
    end
    doc['sections']           = sections.map(&:canonical) if options[:sections]
    doc['data']               = data if options[:data]
    if options[:annotations] && (options[:allowed_to_edit] || options[:allowed_to_review])
      doc['annotations']      = self.annotations_with_authors(options[:account]).map {|a| a.canonical}
    elsif options[:annotations]
      doc['annotations']      = self.annotations.accessible(options[:account]).map {|a| a.canonical}
    end
    if self.mentions
      doc['mentions']         = self.mentions
    end
    doc
  end


  private

  def ensure_titled
    self.title ||= DEFAULT_TITLE
    return true if self.slug
    slugged = title.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n, '').to_s # As ASCII
    slugged.gsub!(/[']+/, '') # Remove all apostrophes.
    slugged.gsub!(/\W+/, ' ') # All non-word characters become spaces.
    slugged.squeeze!(' ')     # Squeeze out runs of spaces.
    slugged.strip!            # Strip surrounding whitespace
    slugged.downcase!         # Ensure lowercase.
    # Truncate to the nearest space.
    if slugged.length > 50
      words = slugged[0...50].split(' ')
      slugged = words[0, words.length - 1].join(' ')
    end
    slugged.gsub!(' ', '-')   # Dasherize spaces.
    self.slug = slugged
  end

  def background_update_asset_access(access_level)
    return update_attributes(:access => access_level) if Rails.env.development?
    RestClient.post(DC_CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      'action'  => 'update_access',
      'inputs'  => [self.id],
      'options' => {'access' => access_level},
      'callback_url' => "#{DC.server_root(:ssl => false)}/import/update_access"
    }.to_json})
  end

end