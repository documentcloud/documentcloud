class Comment < ActiveRecord::Base
  include DC::Access
  
  belongs_to :annotation
  belongs_to :document
  belongs_to :account

  validates_presence_of :text, :access, :document_id, :annotation_id
  
  before_create :ensure_author_name
  
  def ensure_author_name
    if account
      self.author_name = "#{self.account.first_name} #{self.account.last_name}"
    else
      self.author_name = "Anonymous"
    end
  end
  
  named_scope :accessible, lambda { |account|
    has_shared = account && account.accessible_project_ids.present?
    access = []
    access << "(comments.access = #{PUBLIC})"
    access << "((comments.access = #{EXCLUSIVE}) and comments.organization_id = #{account.organization_id})" if account
    access << "(comments.access = #{PRIVATE} and comments.account_id = #{account.id})" if account
    access << "((comments.access = #{EXCLUSIVE}) and memberships.document_id = comments.document_id)" if has_shared
    opts = {:conditions => ["(#{access.join(' or ')})"], :readonly => false}
    if has_shared
      opts[:joins] = <<-EOS
        left outer join
        (select distinct document_id from project_memberships
          where project_id in (#{account.accessible_project_ids.join(',')})) as memberships
        on memberships.document_id = comments.document_id
      EOS
    end
    opts
  }
  
  def canonical(options = {})
    data = {
      'id'         => id,
      'text'       => text,
      'created_at' => created_at
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
