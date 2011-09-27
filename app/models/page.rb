# A single page of a document has its own text saved separately, so that
# in-document searches can be performed.
class Page < ActiveRecord::Base

  IMAGE_SIZES = ActiveSupport::OrderedHash.new
  IMAGE_SIZES['large']      = '1000x'
  IMAGE_SIZES['normal']     = '700x'
  IMAGE_SIZES['small']      = '240x'
  IMAGE_SIZES['thumbnail']  = '60x75!'

  MAX_PAGE_RESULTS = 1000

  include DC::Store::DocumentResource
  include DC::Search::Matchers
  include ActionView::Helpers::SanitizeHelper
  extend ActionView::Helpers::SanitizeHelper::ClassMethods

  belongs_to :document

  validates_numericality_of :page_number, :greater_than_or_equal_to => 1

  before_update :track_text_changes

  searchable do
    text    :text
    integer :document_id
    integer :account_id
    integer :organization_id
    integer :access
    integer :page_number, :stored => true
  end

  def self.search_for_page_numbers(query, document)
    query ||= ''
    query = (query =~ DC::Search::Matchers::QUOTED_VALUE ? query : "\"#{query}\"")
    result = Sunspot.search self do
      fulltext query
      with :document_id, document.id
      order_by :page_number, :asc
      paginate :page => 1, :per_page => MAX_PAGE_RESULTS
    end
    result.hits.map {|hit| hit.stored(:page_number) }
  end

  # The page map is the start and end character (not byte) offset of each
  # page's full text, relative to the combined full text of the entire document.
  def self.refresh_page_map(document)
    pos = -1
    result = self.connection.execute("select id, length(text) from pages where document_id = #{document.id} order by page_number asc;")
    result.each do |item|
      id, length = item['id'].to_i, item['length'].to_i
      Page.update_all("start_offset = #{pos + 1}, end_offset = #{pos + length}", "id = #{id}")
      pos = pos + length
    end
  end

  # Generate the highlighted excerpt of the page text for a given search phrase.
  def self.mentions(doc_id, search_phrase, limit=3)

    # Pull out all the quoted phrases, and regexp escape them.
    phrases = search_phrase.scan(QUOTED_VALUE).map {|r| Regexp.escape(r[1] || r[2]) }
    # Pull out all the bare words, remove boolean bits.
    words   = search_phrase.gsub(QUOTED_VALUE, '').gsub(BOOLEAN, '')
    # Split word parts, and regex escape them.
    words   = words.split(/\s+/).map {|w| Regexp.escape(w) }
    # Create a preferential finder for the bare-words-as-quoted-phrase-case.
    phrases.unshift words.join('\\s+') if words.length > 1
    # Get the array of all possible matches for the FTS search.
    parts   = phrases + words
    # Build the PSQL version of the regex.
    psqlre  = "(" + parts.map {|part| "#{part}(?![a-z0-9])" }.join('|') + ")"
    # Build the Ruby version of the regex.
    rubyre  = /(#{ parts.map {|part| "\\b#{part}\\b" }.join('|') })/i

    conds   = ["document_id = ? and text ~* ?", doc_id, psqlre]
    pages   = Page.all(:conditions => conds, :order => 'page_number asc', :limit => limit)
    count   = Page.count(:conditions => conds)
    {
      :mentions => pages.map {|p| {:page => p.page_number, :text => p.excerpt(rubyre)} }.select {|p| p[:text] },
      :total    => count
    }
  end

  def excerpt(regex, context=150)
    utf     =  text.mb_chars
    match   =  utf.match(regex)
    return nil unless match
    excerpt =  match.pre_match.length >= context ? match.pre_match[-context..-1] : match.pre_match
    excerpt += "<b>#{ match.to_s }</b>"
    excerpt += match.post_match.length >= context ? match.post_match[0..context] : match.post_match
    excerpt
  end

  def contains?(occurrence)
    start_offset <= occurrence.offset && end_offset > occurrence.offset
  end

  def authorized_image_url(size)
    DC::Store::AssetStore.new.authorized_url(document.page_image_path(page_number, size))
  end


  private

  # Make sure that HTML never gets written into the plain text contents.
  # TODO: Should we go back to Calais and blow away entities for little edits?
  def track_text_changes
    return true unless text_changed?
    self.text = strip_tags(text)
    DC::Store::AssetStore.new.save_page_text(self.document, self.page_number, self.text, access)
    @text_changed = true
  end

end