require 'rack/utils'

# Handles flash-based authentication, performed by passing the DC session from
# JavaScript to the Flash object.
class SessionCookieMiddleware

  # Detect Flash's User-Agent header.
  FLASH_MATCHER = /^(Adobe|Shockwave) Flash/

  def initialize(app, session_key = '_session_id')
    @app = app
    @session_key = session_key
  end

  # If a given request is a Flash request, take the "session_key" parameter,
  # and serialize it into the HTTP_COOKIE header.
  #
  # After the app has been called, if the request is not secure, remove the
  # session cookie.
  def call(env)
    if env['HTTP_USER_AGENT'] =~ FLASH_MATCHER
      req = Rack::Request.new(env)
      if req.params['session_key']
        base64 = req.params['session_key']
        env['HTTP_COOKIE'] = "#{@session_key}=#{base64}".freeze
      end
    end
    @app.call(env)
  end
end