class FeaturedController < ApplicationController

  before_action :admin_required, :except => [:index]

  def index
    @reports = FeaturedReport.sorted
    respond_to do |format|
      format.any(:js, :json) do
        json @reports
      end
      format.html { render :layout=>'home' }
      format.rss  { render :layout=>false }
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
      FeaturedReport.update_all( {:present_order=>order}, {:id=>id} )
    end
    render :nothing=>true
  end

  private
  def plucked_attributes
    pick( params, :title, :url, :organization, :article_date, :writeup )
  end
end
