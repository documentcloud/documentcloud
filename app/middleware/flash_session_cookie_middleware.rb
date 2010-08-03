require 'rack/utils'

class FlashSessionCookieMiddleware
  
  FLASH_MATCHER = /^(Adobe|Shockwave) Flash/
  
  def initialize(app, session_key = '_session_id')
    @app = app
    @session_key = session_key
  end

  def call(env)
    if env['HTTP_USER_AGENT'] =~ FLASH_MATCHER
      req = Rack::Request.new(env)
      unless req.params['session_key'].nil?
        env['HTTP_COOKIE'] = "#{@session_key}=#{req.params['session_key']}".freeze
      end
    end
    @app.call(env)
  end
end