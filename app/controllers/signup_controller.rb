class SignupController < ApplicationController
  layout 'home'

  before_action :secure_only

  def index
    @verification_request ||= VerificationRequest.new
  end

  def create
    request_attrs = pick(params, :requester_first_name, :requester_last_name,
      :requester_email, :approver_first_name, :approver_last_name,
      :approver_email, :organization_name, :organization_url, :country,
      :requester_notes, :agreed_to_terms, :authorized_posting, :industry,
      :use_case, :reference_links, :marketing_optin, :in_market)
    @verification_request = VerificationRequest.new(request_attrs)
    
    if @verification_request.save
      LifecycleMailer.verification_request_notification(@verification_request).deliver
    end
    json @verification_request
  end

end
