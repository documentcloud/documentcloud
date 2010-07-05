class HelpController < ApplicationController

  layout false

  def add_users
    markdown :add_users
  end

  def notes
    markdown :notes
  end

  def publish
    markdown :publish
  end

  def search
    markdown :search
  end

  def import
    markdown :import
  end


  private

  def markdown(resource)
    contents = File.read("#{Rails.root}/app/views/help/#{resource}.markdown")
    render :text => RDiscount.new(contents).to_html, :type => :html
  end

end