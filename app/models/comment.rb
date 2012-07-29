class Comment < ActiveRecord::Base
  include DC::Access
  
  belongs_to :annotation
  belongs_to :document
  belongs_to :account

  validates_presence_of :text, :access, :document_id, :annotation_id
  
  before_create :ensure_author_name, :ensure_access
  
  def ensure_author_name
    if account
      self.author_name = "#{self.account.first_name} #{self.account.last_name}"
    else
      self.author_name = "Anonymous"
    end
  end
  
  def ensure_access
    self.access = annotation.comment_access unless access
  end
  
  named_scope :accessible, lambda { |account|
    has_shared = account && account.accessible_project_ids.present?
    access = []
    access << "(comments.access = #{PUBLIC})"
    access << "(comments.access = #{PRIVATE} and comments.account_id = #{account.id})" if account
    access << "(comments.access in (#{ORGANIZATION}, #{EXCLUSIVE}) and comments.organization_id = #{account.organization.id})" if account && !account.freelancer?
    access << "((comments.access = #{EXCLUSIVE}) and comment_memberships.document_id = comments.document_id)" if has_shared
    opts = {:conditions => ["(#{access.join(' or ')})"], :readonly => false}
    if has_shared
      opts[:joins] = <<-EOS
        left outer join
        (select distinct document_id from project_memberships
          where project_id in (#{account.accessible_project_ids.join(',')})) as comment_memberships
        on comment_memberships.document_id = comments.document_id
      EOS
    end
    opts
  }
  
  def accessible_to?(account)
    # short circuit for public view or commenters who don't belong to an organization.
    access == PUBLIC if account.nil? or account.organization.nil?

    this_comment = self
    ( access == PUBLIC ) or
    ( access == PRIVATE and account.owns? this_comment ) or
    ( [EXCLUSIVE, ORGANIZATION].include?(access) and 
      ( account.owns_or_collaborates?(this_comment) or
        account.shared?(this_comment) ))
  end
  
  def canonical(options = {})
    data = {
      'id'         => id,
      'text'       => text,
      'created_at' => created_at,
      'access'     => access
    }
    data.merge!({ 'author' => author_name }) if author_name
    data
  end

  def to_json(opts={})
    canonical(opts).merge({
      'document_id'     => document_id,
      'annotation_id'   => annotation_id,
      'account_id'      => account_id,
      'organization_id' => organization_id
    }).to_json
  end
  
end
