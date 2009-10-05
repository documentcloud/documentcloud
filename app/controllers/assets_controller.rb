# The AssetController deals with serving and caching our static-ish assets.
# This includes JST (Javascript Templates).
class AssetsController < ApplicationController
  
  caches_page :jst, :javascripts, :stylesheets
  
  # For the moment, we have one, large javascript template cache.
  # Later, imagine breaking it up into workspace, search, and embedded portions.
  def jst
    jst_paths = Dir[RAILS_ROOT + '/app/views/jst/**/*.jst']
    templates = []
    jst_paths.each do |path|
      template_name = path.match(/\/jst\/(\S+)\.jst\Z/)[1]
      template_name = template_name.gsub('/', '_').upcase
      contents = File.read(path).gsub(/\n/, '').gsub("'", '\\\\\'')
      templates << "#{template_name} : $.template('#{contents}')"
    end
    cache = "window.dc.templates = { #{templates.join(",\n")} };"
    render :js => cache
  end
  
  def javascripts
    script = DC::Asset::Merger.new.compile_js(ASSET_CONFIG[:javascripts])
    render :js => script
  end
  
  def stylesheets
    styles = DC::Asset::Merger.new.compile_css(ASSET_CONFIG[:stylesheets])
    render :text => styles, :content_type => 'text/css'
  end
  
end