secrets = DC::SECRETS['omniauth']

if secrets.blank?
  STDERR.puts "OmniAuth secrets are not available.  Not performing initialization"
else

  # For Google: Remember to customize the redirect URI for the key to be: /auth/google_oauth2/callback
  # If you do happen to forget and do so later, REDOWNLOAD the key, it changes every time you edit the settings.

  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :twitter  , secrets['twitter']['key'], secrets['twitter']['secret']
    provider :facebook , secrets['facebook']['key'], secrets['facebook']['secret'], { :scope => 'email' }
    provider :google_oauth2, secrets['google']['key'], secrets['google']['secret'], { :access_type=>'online',:approval_prompt=>''}
  end


  # If a third party auth session is started but then the person selects cancel instead of completing
  # the session, then the below block gets called.
  OmniAuth.config.on_failure = Proc.new do |env|
    error = env['omniauth.error.type']
    origin = (env['omniauth.origin'] &&CGI.unescape( env['omniauth.origin'] ) ) || ''
    new_path = "#{env['SCRIPT_NAME']}#{OmniAuth.config.path_prefix}/failure?message=#{error}&origin=#{origin}"
    Rack::Response.new(["302 Moved"], 302, 'Location' => new_path).finish
  end

end
