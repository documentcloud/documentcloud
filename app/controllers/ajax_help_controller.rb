class AjaxHelpController < ApplicationController

  PAGES = [:index, :tour, :public, :accounts, :searching, :uploading, :troubleshooting,
    :modification, :notes, :collaboration, :privacy, :publishing, :api]

  PAGE_TITLES = {
    :index            => 'Introduction',
    :tour             => 'Guided Tour',
    :public           => 'The Public Catalog',
    :accounts         => 'Adding Accounts',
    :searching        => 'Searching Documents',
    :uploading        => 'Uploading Documents',
    :troubleshooting  => 'Troubleshooting Failed Uploads',
    :modification     => 'Document Modification',
    :privacy          => 'Privacy',
    :collaboration    => 'Collaboration',
    :notes            => 'Editing Notes and Sections',
    :publishing       => 'Publishing &amp; Embedding',
    :api              => 'API'
  }

  layout false

  def contact_us
    return bad_request unless params[:message]
    LifecycleMailer.deliver_contact_us(current_account, params)
    json nil
  end

  PAGES.each do |resource|
    class_eval "def #{resource}; markdown(:#{resource}); end"
  end

  private

  def markdown(resource)
    contents = File.read("#{Rails.root}/app/views/help/#{resource}.markdown")
    links_filename = "#{Rails.root}/app/views/help/links/#{resource}_ajax_links.markdown"
    links = File.exists?(links_filename) ? File.read(links_filename) : ""
    render :text => RDiscount.new(contents+links).to_html, :type => :html
  end

end
