class DocumentsController < ApplicationController
  layout nil

  before_filter(:bouncer, :only => [:show]) if Rails.env.staging?
  before_filter :login_required, :only => [:update, :destroy, :entities, :dates, :published, :unpublished]

  SIZE_EXTRACTOR        = /-(\w+)\Z/
  PAGE_NUMBER_EXTRACTOR = /-p(\d+)/

  def show
    doc = current_document(true)
    return forbidden if doc.nil? && Document.exists?(params[:id].to_i)
    return not_found unless doc
    respond_to do |format|
      format.pdf  { redirect_to(doc.pdf_url) }
      format.text { redirect_to(doc.full_text_url) }
      format.html do
        return if date_requested?
        return if entity_requested?
        @edits_enabled = true
      end
      format.json do
        @response = doc.canonical
        return if jsonp_request?
        render :json => @response
      end
      format.js do
        js = "DV.loadJSON(#{doc.canonical.to_json});"
        cache_page js if doc.cacheable?
        render :js => js
      end
      format.xml do
        render :xml => doc.canonical.to_xml(:root => 'document')
      end
      format.rdf do
        @doc = doc
      end
    end
  end

  def update
    return not_found unless doc = current_document(true)
    attrs = pick(:model, :access, :title, :description, :source, :related_article, :remote_url)
    success = doc.secure_update attrs, current_account
    return json({:model => doc}, 403) unless success
    expire_page doc.canonical_cache_path if doc.cacheable?
    json :model => doc
  end

  def destroy
    return not_found unless doc = current_document(true)
    if !current_account.owns_or_administers?(doc)
      doc.errors.add_to_base "You don't have permission to delete the document."
      return json(doc, 403)
    end
    expire_page doc.canonical_cache_path if doc.cacheable?
    doc.destroy
    json nil
  end

  def loader
    render :action => 'loader', :content_type => :js
  end

  # TODO: Access-control this:
  def entities
    json 'entities' => Entity.all(:conditions => {:document_id => params[:ids]})
  end

  # TODO: Access-control this:
  def entity
    entities = Entity.search_in_documents(params[:kind], params[:value], params[:ids])
    json({'entities' => entities}.to_json(:include_excerpts => true))
  end

  # TODO: Access-control this:
  def dates
    return json({'date' => EntityDate.find(params[:id])}.to_json(:include_excerpts => true)) if params[:id]
    dates = EntityDate.find_all_by_document_id(params[:ids], :include => [:document])
    json({'dates' => dates}.to_json)
  end

  # Allows us to poll for status updates in the in-progress document uploads.
  def status
    docs = Document.owned_by(current_account).all(:conditions => {:id => params[:ids]})
    json 'documents' => docs
  end

  def queue_length
    json 'queue_length' => Document.pending.count
  end

  def send_pdf
    return not_found unless current_document(true)
    redirect_to(current_document.pdf_url(:direct))
  end

  def send_page_image
    return not_found unless current_page
    size = params[:page_name][SIZE_EXTRACTOR, 1]
    redirect_to(current_page.authorized_image_url(size))
  end

  def send_full_text
    send_data(current_document(true).text, :disposition => 'inline', :type => :txt)
  end

  def send_page_text
    return not_found unless current_page
    @response = current_page.text
    return if jsonp_request?
    render :text => @response
  end

  def set_page_text
    return not_found unless current_page
    return forbidden unless current_account.allowed_to_edit?(current_page)
    json current_page.update_attributes(pick(params, :text))
  end

  def search
    doc       = current_document(true)
    pages     = Page.search_for_page_numbers(params[:q], doc)
    @response = {'query' => params[:q], 'results' => pages}
    return if jsonp_request?
    render :json => @response
  end

  def preview
    render :action => 'show'
  end


  private

  def date_requested?
    return false unless params[:date]
    date = Time.at(params[:date].to_i).to_date
    meta = current_document.entity_dates.first(:conditions => {:date => date})
    redirect_to current_document.document_viewer_url(:date => meta)
  end

  def entity_requested?
    return false unless params[:entity]
    meta = current_document.entities.find(params[:entity])
    redirect_to current_document.document_viewer_url(:entity => meta, :page => params[:page], :offset => params[:offset])
  end

  def current_document(exists=false)
    @current_document ||= exists ?
      Document.accessible(current_account, current_organization).find_by_id(params[:id].to_i) :
      Document.new(:id => params[:id].to_i)
  end

  def current_page
    num = params[:page_name][PAGE_NUMBER_EXTRACTOR, 1]
    return false unless num
    return false unless current_document(true)
    @current_page ||= current_document.pages.find_by_page_number(num.to_i)
  end

end