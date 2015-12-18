class ProjectsController < ApplicationController

  before_action :login_required

  READONLY_ACTIONS = [
    :index, :documents
  ]
  before_action :read_only_error, :except => READONLY_ACTIONS if read_only?

  def index
    json Project.visible.accessible(current_account)
  end

  def create
    json current_account.projects.create(pick(params, :title, :description, :document_ids))
  end

  def update
    data = pick(params, :title, :description)
    current_project.update_attributes data
    json current_project.reload
  end

  def destroy
    current_project(true).destroy
    json nil
  end

  def documents
    json current_project.documents
  end

  def add_documents
    ids = params[:document_ids].map(&:to_i)
    doc_ids = Document.accessible(current_account, current_organization).where({:id => ids}).pluck('id')
    current_project.add_documents( doc_ids )
    json current_project
  end

  def remove_documents
    ids = params[:document_ids].map(&:to_i)
    doc_ids = Document.accessible(current_account, current_organization).where({:id => ids}).pluck('id')
    current_project.remove_documents( doc_ids )
    json current_project
  end

  private

  def current_project(only_owner=false)
    return @current_project if @current_project
    base = only_owner ? current_account.projects : Project.accessible(current_account)
    @current_project = base.find(params[:id])
  end

end
