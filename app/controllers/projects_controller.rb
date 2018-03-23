class ProjectsController < ApplicationController

  before_action :login_required, except: :show

  READONLY_ACTIONS = [
    :index, :documents, :show
  ]
  before_action :read_only_error, :except => READONLY_ACTIONS if read_only?

  def show
    # PLEASE BE CAREFUL WITH THIS ACTION
    #
    # It was intentionally authored in spite of ProjectsController#current_project
    # in order to hack around the notion that projects can be public objects
    # and not merely objects viewable if you have edit permissions for them.
    @project = Project.where(hidden:false).find(params[:id])
    return not_found unless @project
    
    respond_to do |format|
      format.html do
        @organization_id = @project.account.organization_id
        render(layout: 'new')
      end
      format.json do
        documents = @project.documents.accessible(current_account, current_organization).select(:id,:slug)
        json({
          id: @project.slug,
          title: @project.title,
          documents: documents.first(10000).map{ |document| document.canonical_url(:html) }
        }.as_json)
      end
    end
  end

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
=begin
  Okay i want to add a notion of publicness.
  The notions that a project has are:
    - projects you own
    - projects shared with you
  
  The current project is a project you can edit (which you own or have had shared w/ you)
  
  There should be public projects.
  
  Having a list of public projects and integer ids means that folks can enumerate projects
  (they already can via search tho) and find groupings of public documents which may reveal
  investigations underway.
  
  Need a mechanism to indicate the privacy/publicness of a project.
  Really need to overhaul the search index.
=end
  def current_project(only_owner=false)
    return @current_project if @current_project
    base = only_owner ? current_account.projects : Project.accessible(current_account)
    @current_project = base.find(params[:id])
  end
  
end
