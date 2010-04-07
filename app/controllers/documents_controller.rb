class DocumentsController < ApplicationController
  layout nil

  before_filter(:bouncer, :only => [:show]) if Rails.env.staging?
  before_filter :login_required, :only => [:update, :destroy, :entities, :dates]

  caches_page :show, :if => lambda {|c| c.request.format.js? }

  SIZE_EXTRACTOR        = /-(\w+)\Z/
  PAGE_NUMBER_EXTRACTOR = /-p(\d+)/

  def show
    return unless request.format.json? || request.format.js? || login_required
    return not_found unless current_document(true)
    respond_to do |format|
      format.pdf  { redirect_to(current_document.pdf_url) }
      format.text { redirect_to(current_document.full_text_url) }
      format.html do
        return if date_requested?
        return if entity_requested?
        @edits_enabled = true
      end
      format.json do
        @response = current_document.canonical
        return if jsonp_request?
        render :json => @response
      end
      format.js do
        @response = current_document.canonical
      end
    end
  end

  def update
    return not_found unless doc = current_document(true)
    if !current_account.owns_or_administers?(doc)
      doc.errors.add_to_base "You don't have permission to update the document."
      return json(doc, 403)
    end
    json = JSON.parse(params[:json]).symbolize_keys
    access = json[:access] && json[:access].to_i
    doc.set_access(access) if access && current_document.access != access
    [:description, :title, :source, :remote_url, :related_article].each do |att|
      doc.update_attributes(att => json[att]) if json[att]
    end
    expire_page doc.canonical_cache_path
    json doc
  end

  def destroy
    return not_found unless doc = current_document(true)
    if !current_account.owns_or_administers?(doc)
      doc.errors.add_to_base "You don't have permission to delete the document."
      return json(doc, 403)
    end
    expire_page doc.canonical_cache_path
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
  def dates
    dates = EntityDate.all(:conditions => {:document_id => params[:ids]})
    json 'dates' => dates
  end

  # Allows us to poll for status updates in the in-progress document uploads.
  def status
    docs = Document.owned_by(current_account).all(:conditions => {:id => params[:ids]})
    json 'documents' => docs
  end

  def send_pdf
    redirect_to(current_document(true).pdf_url(:direct))
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
    return forbidden unless current_account.owns_or_administers?(current_page)
    json current_page.update_attributes(pick(params, :text))
  end

  def search
    doc          = current_document(true)
    page_numbers = doc.pages.search_text(params[:q]).map(&:page_number)
    @response    = {'query' => params[:q], 'results' => page_numbers}
    return if jsonp_request?
    render :json => @response
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
    redirect_to current_document.document_viewer_url(:entity => meta)
  end

  def current_document(exists=false)
    @current_document ||= exists ?
      Document.accessible(current_account, current_organization).find_by_id(params[:id].to_i) :
      Document.new(:id => params[:id])
  end

  def current_page
    num = params[:page_name][PAGE_NUMBER_EXTRACTOR, 1]
    return bad_request unless num
    @current_page ||= current_document(true).pages.find_by_page_number(num.to_i)
  end

end