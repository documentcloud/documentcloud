# Keep the entire DC namespace unloadable in development, so that most of the
# /lib folder code will be refreshed for each request.
# ActiveSupport::Dependencies.explicitly_unloadable_constants << 'DC'


require 'dc'
