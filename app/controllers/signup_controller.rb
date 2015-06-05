class SignupController < ApplicationController
  layout 'home'

  def index
    # @verification_request ||= VerificationRequest.find_by_signup_key(params[:key])
    @verification_request ||= VerificationRequest.new

    @country_options           = [['United States', 'US'], ['Canada', 'CN']]
    @display_language_options  = [['English', 'eng'], ['Spanish', 'spa']]
    @document_language_options = [['English', 'eng'], ['Spanish', 'spa'], ['Mandarin', 'chi']]
    @status_options            = [['Pending', 1], ['Denied', 0], ['Approved', 3]]
  end

end
