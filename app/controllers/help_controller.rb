class HelpController < ApplicationController

  PAGES = [:index, :accounts, :notes, :publishing, :searching, :privacy, :uploading, :collaboration, :troubleshooting, :tour]

  layout false

  before_filter :login_required

  def contact_us
    LifecycleMailer.deliver_contact_us(current_account, params[:message])
    json nil
  end

  PAGES.each do |resource|
    class_eval "def #{resource}; markdown(:#{resource}); end"
  end


  private

  def markdown(resource)
    contents = File.read("#{Rails.root}/app/views/help/#{resource}.markdown")
    render :text => RDiscount.new(contents).to_html, :type => :html
  end

end