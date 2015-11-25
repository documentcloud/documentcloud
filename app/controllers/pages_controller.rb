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
    return forbidden if Document.exists?(params[:document_id]) and not current_document
    return not_found unless current_page
    respond_to do |format|
      format.html do
        @page_of_title = "#{@current_page.page_number} of #{@current_document.title}"
      end
      
      format.json do
        @response = current_document.canonical.merge({page: params[:page_number]})
        json_response
      end
    end
  end
  
  private
  
  def current_document(exists=false)
    @current_document ||= exists ?
      Document.accessible(current_account, current_organization).find_by_id(params[:id].to_i) :
      Document.new(:id => params[:id].to_i)
  end

  def current_page
    num = params[:page_number]
    return false unless num
    return false unless current_document(true)
    @current_page ||= current_document.pages.find_by_page_number(num.to_i)
  end
end