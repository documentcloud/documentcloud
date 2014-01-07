# -*- coding: utf-8 -*-
class Document < ActiveRecord::Base
  include DC::Access
  include ActionView::Helpers::TextHelper

  include DocumentConcerns::Annotatable
  include DocumentConcerns::Canonical
  include DocumentConcerns::Searchable
  # Accessors and constants:

  attr_accessor :mentions, :total_mentions, :annotation_count, :hits
  attr_writer   :organization_name, :organization_slug, :display_language, :account_name, :account_slug

  DEFAULT_TITLE = "Untitled Document"

  MINIMUM_POPULAR = 100

  CONCURRENT_UPLOAD_LIMIT = 10

  DISPLAY_DATETIME_FORMAT = "%I:%M %p – %a %b %d, %Y"

 
  DEFAULT_IMPORT_OPTIONS = {
    :access => nil, :text_only => false, :email_me => false, :force_ocr => false, :secure => false
  }

  # If the Document.pending count is greater than this number, send a warning.
  WARN_QUEUE_LENGTH = 150

  # DB Associations:

  belongs_to :account
  belongs_to :organization

  has_one  :docdata,              :dependent   => :destroy, :inverse_of=>:document
  has_many :pages,                :dependent   => :destroy, :inverse_of=>:document
  has_many :entities,             :dependent   => :destroy, :inverse_of=>:document
  has_many :entity_dates,         :dependent   => :destroy
  has_many :sections,             :dependent   => :destroy
  has_many :annotations,          :dependent   => :destroy
  has_many :remote_urls,          :dependent   => :destroy
  has_many :project_memberships,  :dependent   => :destroy
  has_many :projects,             :through     => :project_memberships


  has_many :reviewer_projects,     -> { where( :hidden => true) },
                                     :through     => :project_memberships,
                                     :source      => :project

  has_many :duplicates, ->(document) {
    where(["access in (?) and id != #{document.id} and text_changed = false", ACCESS_SUCCEEDED ])
  }, :foreign_key=>'file_hash', :primary_key=>'file_hash', :class_name=>"Document"

  validates :organization_id, :account_id, :access, :page_count, :title, :slug, :presence=>true

  validates :language, :inclusion => { :in => DC::Language::SUPPORTED }

  before_validation :ensure_titled, :on=>:create
  before_validation :ensure_language_is_valid

  after_destroy :delete_assets

  # Sanitizations (title handled separately):
  text_attr :source, :related_article, :remote_url
  styleable_attr :description

  delegate :slug, :to => :organization, :allow_nil => true, :prefix => true
  delegate :slug, :to => :account,      :allow_nil => true, :prefix => true

  # Scopes:

  scope :chronological, -> { order('created_at desc') }

  # NB: This is *not* efficient.
  scope :random,        -> { order('random()') }

  scope :owned_by, ->(account) { where( :account_id => account.id ) }

  scope :published,     ->{  where( 'remote_url is not null or detected_remote_url is not null' ) }
  scope :unpublished,   ->{  where( 'remote_url is null and detected_remote_url is null' ) }

  scope :pending,       ->{ where( :access => PENDING ) }
  scope :failed,        ->{ where( :access => ERROR   ) }
  scope :unrestricted,  ->{ where( :access => PUBLIC_LEVELS ) }
  scope :restricted,    ->{ where( :access => [PRIVATE, ORGANIZATION] ) }
  scope :finished,      ->{ where( :access => [PUBLIC, PRIVATE, ORGANIZATION, PREMODERATED, POSTMODERATED] ) }

  scope :popular,       ->{ where( ["hit_count > ?", MINIMUM_POPULAR] ) }

  scope :due,           ->( time=Time.now.utc ) { where( ["publish_at <= ?", time  ] ) }

  scope :since,         ->(time){ where( ["created_at >= ?", time] ) if time }


  # Restrict accessible documents for a given account/organization.
  # Either the document itself is public, or it belongs to us, or it belongs to
  # our organization and we're allowed to see it, or it belongs to a project
  # that's been shared with us.
  scope :accessible, lambda {|account, org|
    has_shared = account && account.accessible_project_ids.present?
    access = []
    access << "(documents.access in (#{PUBLIC_LEVELS.join(",")}))"
    access << "(documents.access in (#{PRIVATE}, #{PENDING}, #{ERROR}, #{ORGANIZATION}, #{EXCLUSIVE}) and documents.account_id = #{account.id})" if account
    access << "(documents.access in (#{ORGANIZATION}, #{EXCLUSIVE}) and documents.organization_id = #{org.id})" if org && account && !account.freelancer?
    access << "(memberships.document_id = documents.id)" if has_shared
    query = where( access.join(' or ') )
    if has_shared
        query = query.joins( "
          left outer join
          (select distinct document_id from project_memberships
            where project_id in (#{account.accessible_project_ids.join(',')})) as memberships
          on memberships.document_id = documents.id
        ")
    end
    query.readonly(false)
  }

  # Upload a new document, starting the import process.
  def self.upload(params, account, organization)
    name     = params[:url] || params[:file].original_filename
    title    = params[:title] || File.basename(name, File.extname(name)).titleize
    file_ext = File.extname(name).downcase[1..-1]
    doc = self.create!(
      :organization_id    => organization.id,
      :account_id         => account.id,
      :access             => PENDING,
      :page_count         => 0,
      :title              => title,
      :description        => params[:description],
      :source             => params[:source],
      :related_article    => params[:related_article],
      :remote_url         => params[:published_url] || params[:remote_url],
      :language           => params[:language] || account.language,
      :original_extension => file_ext
    )

    access   = params[:make_public] ? PUBLIC :
               (params[:access] ? ACCESS_MAP[params[:access].to_sym] : PRIVATE)
    email_me = params[:email_me] ? params[:email_me].to_i : false

    import_options = {
      :access => access,
      :email_me => email_me,
      :secure => params[:secure],
      :organization_id => organization.id,
      :account_id => account.id
    }
    if params[:url]
      import_options.merge!(:url => params[:url])
    else
      DC::Store::AssetStore.new.save_original(doc, params[:file].path, access)
    end
    doc.queue_import(import_options)
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
    record_job(RestClient.post(DC::CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
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
      self.errors.add(:base, "You don't have permission to update the document." )
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
    self.pages.order('page_number asc').pluck(:text).join('')
  end

  def ordered_sections
    sections.order('page_number asc')
  end


  # Return an array of all of the document entity values for a given type,
  # for Solr indexing purposes.
  def entity_values(kind)
    self.entities.kind(kind.to_s).pluck('value')
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

  # updates the document's character count by detecting the
  # largest end_offset off our pages.
  def reset_char_count!
    update_attributes :char_count => 1+self.pages.maximum(:end_offset).to_i
  end

  # Does this document have a title?
  def titled?
    title.present? && (title != DEFAULT_TITLE)
  end

  def public?
    self.access == PUBLIC
  end

  def publicly_accessible?
    [PUBLIC, EXCLUSIVE, PREMODERATED, POSTMODERATED].include? access
  end
  alias_method :cacheable?, :publicly_accessible?

  def published?
    publicly_accessible? && (remote_url.present? || detected_remote_url.present?)
  end

  def published_url
    remote_url || detected_remote_url
  end

  def commentable?(account)
    [ PREMODERATED, POSTMODERATED ].include?(access) or ( account && account.allowed_to_comment?(self) )
  end

  # When the access level changes, all sub-resource and asset permissions
  # need to be updated.
  def set_access(access_level)
    changes = {:access => PENDING}
    changes[:publish_at] = nil if PUBLIC_LEVELS.include? access_level
    update_attributes changes
    background_update_asset_access access_level
  end

  # If we need to change the ownership of the document, we have to propagate
  # the change to all associated models.
  def set_owner(account)
    unless org = account.organization
      errors.add(:account, "must have an organization") and return false
    end
    update_attributes(:account_id => account.id, :organization_id => org.id)
    sql = "account_id = #{account.id}, organization_id = #{org.id}"
    self.pages.update_all( sql )
    self.entities.update_all( sql )
    self.entity_dates.update_all( sql )
  end

  def organization_name
    @organization_name ||= organization.name
  end

  def display_language
    @display_language ||= organization.language
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

  def reviewers
    return [] unless reviewer_projects.empty?
    reviewer_projects.map{ |project| project.collaborators }.flatten.uniq
  end

  def add_reviewer(account, creator)
    unless project = reviewer_projects.first
      project = Project.create :hidden => true
      project.set_documents([id])
    end
    project.add_collaborator account, creator
  end

  def remove_reviewer(account)
    reviewer_projects.first.remove_collaborator(account)
  end

  def reviewer_inviter(reviewer_account)
    collab = Collaboration.first(:conditions => [
      "account_id = ? AND project_id = ? AND creator_id IS NOT NULL",
      reviewer_account.id,
      reviewer_projects.first.id
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


  def reprocess_entities
    RestClient.post(DC::CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      'action'  => 'reprocess_entities',
      'inputs'  => [id]
    }.to_json})
  end

  # Keep a local ProcessingJob record of this active CloudCrowd Job.
  # job_json can either be a String or a Hash, e.g. {job: '{\"action\":\"document_import\",\...}'}
  def record_job(job_json)
    job = job_json.is_a?(Hash) ? job_json.symbolize_keys[:job] : JSON.parse(job_json)
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
    record_job(RestClient.post(DC::CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      'action'  => 'reindex_document',
      'inputs'  => [id],
      'options' => {
        :id      => id,
        :access  => eventual_access
      }
    }.to_json}).body)
  end

  # Redactions is an array of objects: {'page' => 1, 'location' => '30,50,50,10'}
  # The color can be 'black' or 'red'.
  def redact_pages(redactions, color='black')
    eventual_access = access || PRIVATE

    attributes = {:access => PENDING}
    unless original_extension.nil? or original_extension.downcase == 'pdf'
      asset_store.delete_original(self)
      attributes[:original_extension] = 'pdf'
    end

    update_attributes attributes
    record_job(RestClient.post(DC::CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      'action'  => 'redact_pages',
      'inputs'  => [id],
      'options' => {
        :id => id,
        :redactions => redactions,
        :access => eventual_access,
        :color => color
      }
    }.to_json}).body)
  end

  def remove_pages(pages, replace_pages_start=nil, insert_document_count=nil)
    eventual_access = access || PRIVATE
    update_attributes :access => PENDING
    record_job(RestClient.post(DC::CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
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
    record_job(RestClient.post(DC::CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
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
    RestClient.post(DC::CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
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


  # Updates file_size and file_hash
  # Will default to reading the data from the asset_store
  # or can be passed arbitrary data such as from a file on disk
  def update_file_metadata( data = asset_store.read_original(self) )
    update_attributes!( :file_size => data.bytesize, :file_hash => Digest::SHA1.hexdigest( data ) )
  end

  # TODO: Put this elsewhere
  def self.format_title_slug(title)

    # slugged = title.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n, '').to_s # As ASCII
    # slugged.gsub!(/[']+/, '') # Remove all apostrophes.
    # slugged.gsub!(/\W+/, ' ') # All non-word characters become spaces.
    # slugged.squeeze!(' ')     # Squeeze out runs of spaces.
    # slugged.strip!            # Strip surrounding whitespace
    # slugged.downcase!         # Ensure lowercase.
    # # Truncate to the nearest space.
    # if slugged.length > 50
    #   words = slugged[0...50].split(' ')
    #   slugged = words[0, words.length - 1].join(' ')
    # end
    # slugged.gsub!(' ', '-')   # Dasherize spaces.

    slugged = title.to_url # .to_url is part of StringEx(lite)
    if slugged.length > 50
      words = slugged[0...50].split('-')
      slugged = words[0, words.length - 1].join('-')
    end

    return slugged
  end

  private
  def ensure_language_is_valid
    self.language = DC::Language::DEFAULT unless DC::Language::SUPPORTED.include?(language)
  end

  def ensure_titled
    self.title ||= DEFAULT_TITLE
    return true if self.slug

    self.slug = Document.format_title_slug(title)
  end

  def background_update_asset_access(access_level)
    return update_attributes(:access => access_level) if Rails.env.development?
    RestClient.post(DC::CONFIG['cloud_crowd_server'] + '/jobs', {:job => {
      'action'  => 'update_access',
      'inputs'  => [self.id],
      'options' => {'access' => access_level},
      'callback_url' => "#{DC.server_root(:ssl => false)}/import/update_access"
    }.to_json})
  end

end
