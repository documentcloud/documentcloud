class FeaturedController < ApplicationController
  
  before_action :secure_only
  before_action :current_account
  before_action :admin_required, :except => [:index]
  before_action :read_only_error if read_only?

  def index
    @reports = FeaturedReport.sorted
    respond_to do |format|
      format.any(:js, :json) do
        json @reports
      end
      format.html { render :layout => 'home' }
      format.rss  { render :layout => nil }
    end
  end

  def create
    json FeaturedReport.create plucked_attributes
  end

  def update
    report = FeaturedReport.find(params[:id])
    report.update_attributes( plucked_attributes )
    json report
  end

  def destroy
    FeaturedReport.find(params[:id]).destroy
    render :nothing=>true
  end

  def present_order
    params[:order].each_with_index do | id, order |
      report = FeaturedReport.find(id)
      report.present_order = order
      report.save!
    end
    render :nothing=>true
  end

  private
  def plucked_attributes
    pick( params, :title, :url, :organization, :article_date, :writeup )
  end
end
