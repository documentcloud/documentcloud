class PagesController < ApplicationController
  layout nil

  before_action :bouncer,             :only => [:show] if exclusive_access?
  #before_action :login_required,      :only => [:update, :destroy]
  before_action :prefer_secure,       :only => [:show]
  #before_action :api_login_optional,  :only => [:send_full_text, :send_pdf, :send_page_text, :send_page_image]
  before_action :set_p3p_header,      :only => [:show]
  after_action  :allow_iframe,        :only => [:show]
  #skip_before_action :verify_authenticity_token, :only => [:send_page_text]
  
  def show
    
  end
end