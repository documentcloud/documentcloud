class Annotation < ActiveRecord::Base

  include DC::Store::DocumentResource
  include DC::Access

  belongs_to :document
  belongs_to :account # NB: This account is not the owner of the document.
                      #     Rather, it is the author of the annotation.

  belongs_to :organization
  has_many :project_memberships, :through => :document

  attr_accessor :author

  validates :title, :page_number, :presence=>true

  before_validation :ensure_title

  after_create  :reset_public_note_count
  after_destroy :reset_public_note_count

  # Sanitizations:
  text_attr :title
  html_attr :content, :level=>:super_relaxed

  scope :accessible, lambda { |account|
    has_shared = account && account.accessible_project_ids.present?

    # Notes accessible under the following circumstances:
    access = []
    joins  = []

    # A note is public
    access << "(annotations.access in (#{PUBLIC_LEVELS.join(",")}))"

    if account
      # A note belongs to the accessing account
      access << "(annotations.access = #{PRIVATE} and annotations.account_id = #{account.id})"

      # An draft (EXCLUSIVE) note and the accessing account belong to the same organization
      joins << <<-EOS
        left outer join memberships on
          (annotations.organization_id = memberships.organization_id and
           memberships.account_id = #{account.id})
      EOS
      access << "(annotations.access = #{EXCLUSIVE} and annotations.organization_id = memberships.organization_id)"
    end


    if has_shared
      # A draft (EXCLUSIVE) note is on a document shared with the accessing account
      access << "((annotations.access = #{EXCLUSIVE}) and projects.document_id = annotations.document_id)"
      joins  << <<-EOS
        left outer join
        (select distinct document_id from project_memberships
          where project_id in (#{account.accessible_project_ids.join(',')})) as projects
        on projects.document_id = annotations.document_id
      EOS
    end
    where( "(#{access.join(' or ')})" ).joins( joins.join("\n") ).readonly(false)
  }

  scope :owned_by, lambda { |account|
    where( :account_id => account.id )
  }

  scope :unrestricted, lambda{ where( :access => PUBLIC_LEVELS ) }

  # Annotations are not indexed for the time being.

  # searchable do
  #   text :title, :boost => 2.0
  #   text :content
  #
  #   integer :document_id
  #   integer :account_id
  #   integer :organization_id
  #   integer :access
  #   time    :created_at
  # end

  def self.counts_for_documents(account, docs)
    doc_ids = docs.map {|doc| doc.id }
    self.accessible(account).where({:document_id => doc_ids}).group('annotations.document_id').count
  end

  def self.populate_author_info(notes, current_account=nil)
    return if notes.empty?
    account_sql = <<-EOS
      SELECT DISTINCT accounts.id, accounts.first_name, accounts.last_name,
                      organizations.name as organization_name
      FROM accounts
      INNER JOIN annotations   ON annotations.account_id = accounts.id
      INNER JOIN organizations ON organizations.id = annotations.organization_id
      WHERE annotations.id in (#{notes.map(&:id).join(',')})
    EOS
    rows = Account.connection.select_all(account_sql)
    account_map = rows.inject({}) do |memo, acc|
      memo[acc['id'].to_i] = acc unless acc.nil?
      memo
    end
    notes.each do |note|
      author = account_map[note.account_id]
      note.author = {
        :full_name         => author ? "#{author['first_name']} #{author['last_name']}" : "Unattributed",
        :account_id        => note.account_id,
        :owns_note         => current_account && current_account.id == note.account_id,
        :organization_name => author ? author['organization_name'] : nil
      }
    end
  end

  def self.public_note_counts_by_organization
    self.unrestricted
      .joins(:document)
      .where(["documents.access in (?)", PUBLIC_LEVELS])
      .group('annotations.organization_id')
      .count
  end

  def page
    document.pages.find_by_page_number(page_number)
  end

  def access_name
    ACCESS_NAMES[access]
  end

  def cacheable?
    PUBLIC_LEVELS.include?(access) && document.cacheable?
  end

  def coordinates
    return nil unless location
    coords = location.split(',').map { |loc| loc.to_i }
    transform_coordinates_to_legacy({
      top:    coords[0],
      left:   coords[3],
      right:  coords[1],
      height: coords[2] - coords[0],
      width:  coords[1] - coords[3],
    })
  end

  def embed_dimensions
    return nil unless coords = coordinates
    page_width = Page::IMAGE_SIZES['normal'].gsub(/x$/, '').to_i
    {
      aspect_ratio:        100.0 * coords[:height] / coords[:width],
      height_pixel:        coords[:height],
      width_pixel:         coords[:width],
      width_percent:       100.0 * page_width / coords[:width],
      offset_top_percent:  -100.0 * coords[:top] / coords[:height],
      offset_left_percent: -100.0 * coords[:left] / coords[:width],
    }
  end

  # `contextual` means "show this thing in the context of its document parent",
  # which right now correlates to its page-anchored version.
  def contextual_url
    File.join(DC.server_root, contextual_path)
  end
  
  def contextual_path
    "#{document.canonical_path(:html)}\#document/p#{page_number}/a#{id}"
  end

  def canonical_url(format = :json, allow_ssl = true)
    File.join(DC.server_root(:ssl => allow_ssl), canonical_path(format))
  end
  
  def canonical_path(format = :json)
    "/documents/#{document.canonical_id}/annotations/#{id}.#{format}"
  end

  def oembed_url
    "#{DC.server_root}/api/oembed.json?url=#{CGI.escape(self.canonical_url(:html))}"
  end
  
  def canonical_js_cache_path
    canonical_path(:js)
  end
  
  # Effective duplicate of `canonical_path()` for explicitness
  def canonical_json_cache_path
    canonical_path(:json)
  end
  
  def cache_paths
    [canonical_js_cache_path, canonical_json_cache_path]
  end

  def anchored_published_url
    "#{document.published_url}\#document/p#{page_number}/a#{id}"
  end

  def canonical(opts={})
    data = {'id' => id, 'page' => page_number, 'title' => title, 'content' => content, 'access' => access_name.to_s }
    data['location'] = {'image' => location} if location
    data['image_url'] = document.page_image_url_template if opts[:include_image_url]
    data['published_url'] = document.published_url || document.canonical_url(:html) if opts[:include_document_url]
    data['canonical_url'] = canonical_url(:html)
    data['resource_url'] = canonical_url(:js)
    data['account_id'] = account_id if [PREMODERATED, POSTMODERATED].include? document.access
    if author
      data.merge!({
        'author'              => author[:full_name],
        'owns_note'           => author[:owns_note],
        'author_organization' => author[:organization_name]
      })
    end
    data
  end

  def reset_public_note_count
    document.reset_public_note_count
  end

  def as_json(opts={})
    canonical.merge({
      'document_id'     => document_id,
      'account_id'      => account_id,
      'organization_id' => organization_id
    })
  end

  private

  # For unknown reasons, we do this
  def transform_coordinates_to_legacy(coords)
    {
      top:    coords[:top]    + 1,
      left:   coords[:left]   - 2,
      right:  coords[:right]     ,
      height: coords[:height]    ,
      width:  coords[:width]  - 8,
    }
  end

  def ensure_title
    self.title = "Untitled Annotation" if title.blank?
  end

end
