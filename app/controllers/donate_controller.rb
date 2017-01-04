class DonateController < ApplicationController
  layout 'new'

  before_action :secure_only
  before_action { not_found } unless DC::CONFIG['accept_donations']

  def index
    @canonical_url      = donate_url
    @donation_levels    = [25, 50, 100, 250]
    @suggested_donation = 50;
  end

  def charge
    @amount = params[:donation_amount_cents]
    begin
      @amount = @amount.gsub('$', '').gsub(',', '').to_i
    rescue
      flash[:error] = 'Charge not completed. Please enter a valid amount in USD ($).'
      redirect_to donate_path
      return
    end

    if @amount < 500
      flash[:error] = "Charge not completed. Donation amount must be at least $5."
      redirect_to donate_path
      return
    end
      
    begin
      Stripe::Charge.create(
        amount:        @amount,
        currency:      'usd',
        source:        params[:stripe_token],
        description:   'DocumentCloud Donation',
        receipt_email: params[:stripe_email],
        metadata: {
          type:  'donation',
          email: params[:stripe_email],
        },
      )
    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to donate_path
    end

    session[:last_donation_amount] = Float(@amount) / 100
    session[:suggested_donation]   = params[:suggested_donation] || 'none'
    redirect_to donate_thanks_path
  end

  def thanks
    if params[:preview]
      @donation_amount = 1000000
    else
      redirect_to donate_path and return unless @donation_amount = session[:last_donation_amount]
      @suggested_donation = session[:suggested_donation]
      # Kill the sessions vars so we don't hit this page twice
      session[:last_donation_amount] = nil
      session[:suggested_donation]   = nil
    end
  end

end
