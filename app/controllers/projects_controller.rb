class ProjectsController < ApplicationController

  before_filter :login_required

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
    json current_project.loaded_documents
  end
  
  def add_documents
    ids = params[:document_ids].map(&:to_i)
    docs = Document.accessible(current_account, current_organization).all(:conditions => {:id => ids}, :select => 'documents.id')
    current_project.add_documents(docs.map(&:id))
    json current_project
  end
  
  def remove_documents
    ids = params[:document_ids].map(&:to_i)
    docs = Document.accessible(current_account, current_organization).all(:conditions => {:id => ids}, :select => 'documents.id')
    current_project.remove_documents(docs.map(&:id))
    json current_project
  end

  private

  def current_project(only_owner=false)
    return @current_project if @current_project
    base = only_owner ? current_account.projects : Project.accessible(current_account)
    @current_project = base.find(params[:id])
  end

end