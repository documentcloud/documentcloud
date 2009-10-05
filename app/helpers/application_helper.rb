# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def stylesheet_asset_tag(*extras)
    base_tags = stylesheet_link_tag(
      Rails.development? ? DC::Asset::Merger::CSS_URLS : '/assets/stylesheets.css')
    base_tags << stylesheet_link_tag(extras)
  end
  
  def javascript_asset_tag(*extras)
    base_tags = javascript_include_tag(
      Rails.development? ? DC::Asset::Merger::JS_URLS : '/assets/javascripts.js')
    base_tags << javascript_include_tag(extras)
  end
  
  def jst_asset_tag
    javascript_include_tag '/assets/jst.js'
  end
  
end

