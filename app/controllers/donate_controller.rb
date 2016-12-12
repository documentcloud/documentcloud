class DonateController < ApplicationController
  layout 'new'

  before_action :secure_only
  before_action { not_found } unless DC::CONFIG['accept_donations']

  def index
    flash.now[:warning] = 'Welcome! This donation page is currently in test mode so <b>donations will not be processed</b>. Use the credit card number <code>4242424242424242</code> to test.' unless Rails.env.development?
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
        amount:      @amount,
        currency:    'usd',
        source:      params[:stripe_token],
        description: 'DocumentCloud Donation',
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
    # Don't let people hit this page twice, so we don't track GA twice
    redirect_to donate_path and return unless @donation_amount = session[:last_donation_amount]
    @suggested_donation = session[:suggested_donation]
    session[:last_donation_amount] = nil
    session[:suggested_donation] = nil
  end

end
