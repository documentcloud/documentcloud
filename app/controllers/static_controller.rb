require 'maruku'

class StaticController < ApplicationController

  Dir.glob(RAILS_ROOT + '/app/views/static/*.markdown').map do |template|
    base = template.match(/([a-z_\-]*)\.markdown$/i)[1]
    caches_page base
    define_method base.to_sym do
      html = Maruku.new(File.read(template)).to_html
      render :inline => html, :layout => true
    end
  end
  
end
