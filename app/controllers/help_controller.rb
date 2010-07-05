class HelpController < ApplicationController

  layout false

  [:add_users, :notes, :publish, :search, :import, :troubleshoot].each do |resource|
    class_eval "def #{resource}; markdown(:#{resource}); end"
  end


  private

  def markdown(resource)
    contents = File.read("#{Rails.root}/app/views/help/#{resource}.markdown")
    render :text => RDiscount.new(contents).to_html, :type => :html
  end

end