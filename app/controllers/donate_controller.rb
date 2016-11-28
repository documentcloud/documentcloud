class DonateController < ApplicationController
  layout 'new'

  before_action :secure_only

  def index
    
  end

  def charge
    @amount = params[:amount]
    @amount = @amount.gsub('$', '').gsub(',', '')
    begin
      @amount = Float(@amount).round(2)
    rescue
      flash[:error] = 'Charge not completed. Please enter a valid amount in USD ($).'
      redirect_to donate_path
      return
    end
    @amount = (@amount * 100).to_i # Cents

    if @amount < 500
      flash[:error] = 'Charge not completed. Donation amount must be at least $5.'
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

    redirect_to donate_thanks_path

    # request.xhr?

    # respond_to do |format|
    #   format.json do
    #   end
    #   format.all do
    #   end
    # end

  end

  def thanks
    
  end

end
