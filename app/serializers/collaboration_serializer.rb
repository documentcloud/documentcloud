class CollaborationSerializer < ActiveModel::Serializer

  attributes :id,
             :account_id,
             :creator_id,
             :membership_id,
             :hidden,
             :project_id,
             :title,
             :account_full_name,
             :annotation_count,
             :document_count,
             :public_url,
             :collaborators
  # TODO use a project serializer and pass the project object
  def project
    Project.find(object.project_id)
  end

  def title
    return '[Untitled Project]' if object.project.title.blank?
    object.project.title
  end

  def account_full_name
    object.project.account_full_name
  end

  def annotation_count
    project.annotation_count(object.account)
  end

  def document_count
    object.project.project_memberships.count
  end

  def public_url
    object.project.public_url
  end

  def collaborators
    object.project.other_collaborators(object.account)
          .map { |c| c.canonical(include_organization: true) }
  end
end
