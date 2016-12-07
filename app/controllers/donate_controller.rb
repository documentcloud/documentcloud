class DonateController < ApplicationController
  layout 'new'

  before_action :secure_only
  before_action { not_found } unless DC::CONFIG['accept_donations']

  def index
    flash.now[:warning] = 'Welcome! This donation page is currently in test mode so <b>donations will not be processed</b>. Use the credit card number <code>4242424242424242</code> to test.'
  end

  def charge
    @amount = params[:final_donation_amount]
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
    redirect_to donate_thanks_path
  end

  def thanks
    @amount = session[:last_donation_amount]
  end

end
