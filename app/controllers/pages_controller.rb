class PagesController < ApplicationController
  layout 'minimal'

  before_action :bouncer,             :only => [:show] if exclusive_access?
  #before_action :login_required,      :only => [:update, :destroy]
  before_action :prefer_secure,       :only => [:show]
  #before_action :api_login_optional,  :only => [:send_full_text, :send_pdf, :send_page_text, :send_page_image]
  before_action :set_p3p_header,      :only => [:show]
  after_action  :allow_iframe,        :only => [:show]
  #skip_before_action :verify_authenticity_token, :only => [:send_page_text]
  
  def show
    document_id = (params[:id] || params[:document_id]).to_i
    return forbidden if Document.exists?(document_id) and not current_document
    return not_found unless current_page

    respond_to do |format|
      format.html do
        if params[:embed] == 'true'
          # We have a special, extremely stripped-down show page for when we're
          # being iframed. The normal show page can also be iframed, but there
          # will be a flash of unwanted layout elements before the JS/CSS 
          # arrives which removes them.
          @embedded = true
          @exclude_analytics = true
          render template: 'pages/show_embedded'
        else
          make_oembeddable(current_page)
        end
      end
      
      format.json do
        @response = current_document_json
        render_cross_origin_json
      end
      
      format.js do
        js = "DV.loadJSON(#{current_document_json});"
        cache_page js if current_document.cacheable?
        render :js => js
      end

      #format.txt { send_page_text }
      
      #format.gif { send_page_image }
    end
  end
  
  private
  
  def current_document_json
    current_document.canonical.merge({page: (params[:page_number] || params[:id])}).to_json
  end

  def current_document
    # in order to hack together non-resourceful route,
    # temporarily use :id
    document_id = (params[:id] || params[:document_id]).to_i
    @current_document ||= Document.accessible(current_account, current_organization).find_by_id(document_id)
  end

  def current_page
    # in order to hack together non-resourceful route,
    # temporarily use :page_number
    num = (params[:page_number] || params[:id]).to_i
    return false unless num
    return false unless current_document
    @current_page ||= current_document.pages.find_by_page_number(num.to_i)
  end
end