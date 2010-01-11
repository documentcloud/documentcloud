class StaticController < ApplicationController

  Dir.glob(RAILS_ROOT + '/app/views/static/*.erb').map do |template|
    base = template.match(/([a-z][a-z_\-]*)\.erb$/i)[1]
    caches_page base
    define_method base.to_sym do
    end
  end

end
