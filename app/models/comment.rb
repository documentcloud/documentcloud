class Comment < ActiveRecord::Base
  include DC::Access
  
  belongs_to :annotation
  belongs_to :document
  belongs_to :commenter

  attr_accessor :author
  
  validates_presence_of :text
  
  named_scope :accessible, lambda { |account|
    has_shared = account && account.accessible_project_ids.present?
    access = []
    #access << "(comments.access = #{PUBLIC})"
    #access << "((comments.access = #{EXCLUSIVE}) and annotations.organization_id = #{account.organization_id})" if account
    #access << "(comments.access = #{PRIVATE} and annotations.commenter_id = #{account.commenter_id})" if account
    #access << "((comments.access = #{EXCLUSIVE}) and memberships.document_id = annotations.document_id)" if has_shared
    opts = {}#{:conditions => ["(#{access.join(' or ')})"], :readonly => false}
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
  
  def self.populate_author_info(comments, current_account=nil)
    commenters = Commenter.all(:conditions => { :id => comments.map(&:commenter_id).uniq } )
    comments.each{ |comment| comment.author = commenters.select{ |commenter| commenter.id == comment.commenter_id }.first }
  end
  
  def canonical(options = {})
    data = {
      'id'         => id,
      'text'       => text,
      'created_at' => created_at
    }
    data.merge!({ 'author' => author }) if author
    data
  end

  def to_json(options={})
    canonical.to_json
  end
  
end
