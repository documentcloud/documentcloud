# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def stylesheet_asset_tag
    if Rails.development?
      DC::Asset::Merger::CSS_URLS.map {|u| stylesheet_link_tag(u) }.join("\n")
    else
      stylesheet_link_tag '/assets/stylesheets.css'
    end
  end
  
  def javascript_asset_tag
    if Rails.development?
      DC::Asset::Merger::JS_URLS.map {|u| javascript_include_tag(u) }.join("\n")
    else
      javascript_include_tag '/assets/javascripts.js'
    end
  end
  
  def jst_asset_tag
    javascript_include_tag '/assets/jst.js'
  end
  
end

