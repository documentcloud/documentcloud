class SignupController < ApplicationController
  layout 'empty'

  before_action :secure_only

  def index
    @verification_request ||= VerificationRequest.new
  end

  def create
    request_attrs = pick(params, :requester_first_name, :requester_last_name,
      :requester_email, :requester_position, :approver_first_name,
      :approver_last_name, :approver_email, :organization_name,
      :organization_url, :country, :requester_notes, :agreed_to_terms,
      :authorized_posting, :industry, :use_case, :reference_links,
      :marketing_optin, :in_market)
    @verification_request = VerificationRequest.new(request_attrs)
    
    if @verification_request.save and not Rails.env.development?
      notify_support_email
      notify_slack
    end

    json @verification_request
  end

  private

  def notify_support_email
    LifecycleMailer.verification_request_notification(@verification_request).deliver_now
  end

  def notify_slack
    hook_url = DC::SECRETS['slack_webhook']
    text = "New account request from #{@verification_request.requester_full_name} (#{@verification_request.organization_name}) in #{Rails.env}"
    data = {:payload => {:text => text, :username => "docbot", :icon_emoji => ":doccloud:"}.to_json}
    RestClient.post(hook_url, data)
  end

end
