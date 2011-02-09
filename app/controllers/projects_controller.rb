class ProjectsController < ApplicationController

  before_filter :login_required

  def index
    json Project.visible.accessible(current_account)
  end

  def create
    json current_account.projects.create(pick(params, :title, :description, :document_ids))
  end

  # TODO: Ensure that the document ids you're adding are for documents you
  # have access to.
  def update
    data = pick(params, :title, :description, :document_ids)
    ids  = (data.delete(:document_ids) || []).map(&:to_i)
    docs = Document.accessible(current_account, current_organization).all(:conditions => {:id => ids}, :select => 'id')
    current_project.set_documents(docs.map(&:id))
    current_project.update_attributes data
    json current_project.reload
  end

  def destroy
    current_project(true).destroy
    json nil
  end

  def documents
    json current_project.loaded_documents
  end


  private

  def current_project(only_owner=false)
    return @current_project if @current_project
    base = only_owner ? current_account.projects : Project.accessible(current_account)
    @current_project = base.find(params[:id])
  end

end