require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Circlet < OmniAuth::Strategies::OAuth2
      # change the class name and the :name option to match your application name
      option :name, :circlet

      uid { raw_info["id"] }

      info do
        {
          first_name: raw_info['first_name']
          last_name: raw_info['last_name']
          email: raw_info['email']
          # and anything else you want to return to your API consumers
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/path-to-url-on-circlet.json').parsed
      end
    end
  end
end
