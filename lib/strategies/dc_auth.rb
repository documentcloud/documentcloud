require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class DCAuth < OmniAuth::Strategies::OAuth2
      #include OmniAuth::Strategy
      # change the class name and the :name option to match your application name
      option :name, :dc_auth
      
      option :client_options, { 
        site: DC::SECRETS['omniauth']['documentcloud']['site'],
        authorize_url: DC::SECRETS['omniauth']['documentcloud']['authorize_url']
      }

      uid { raw_info["id"] }

      info do
        {
          # first_name: raw_info['first_name'],
          # last_name: raw_info['last_name'],
          email: raw_info['email']
          # and anything else you want to return to your API consumers
        }
      end

      def raw_info
        binding.pry
        @raw_info ||= access_token.get("#{DC::SECRETS['omniauth']['documentcloud']['site']}/api/me.json").parsed
      end
    end
  end
end

OmniAuth.config.add_camelization 'dc_auth', 'DCAuth'
