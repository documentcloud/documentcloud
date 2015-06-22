class SignupController < ApplicationController
  layout 'home'

  before_action :secure_only

  def index
    populate_options
    @verification_request ||= VerificationRequest.new
  end

  def create_request
    populate_options
    request_attrs = pick(params[:verification_request], :requester_first_name, :requester_last_name, :requester_email, :approver_first_name, :approver_last_name, :approver_email, :organization_name, :organization_url, :country, :display_language, :document_language, :requester_notes, :agreed_to_terms, :authorized_posting)
    @verification_request = VerificationRequest.new(request_attrs)
    if @verification_request.save
      redirect_to :action => 'thanks'
    else
      render :index
    end
  end

  private

  def populate_options
    @status_options            = [['Pending', 1], ['See Note', 2], ['Approved', 3], ['Denied', 0]]
    @document_language_options = DC::Language::NAMES.invert
    @display_language_options  = {}
    DC::Language::USER.each do |short|
      @display_language_options[DC::Language::NAMES[short]] = short
    end
  end

end
