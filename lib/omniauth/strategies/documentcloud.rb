module OmniAuth
  module Strategies
    class Documentcloud < OmniAuth::Strategies::OAuth2

      secrets = DC::SECRETS['omniauth']

      option :name, :documentcloud

      # https://github.com/intridea/omniauth-oauth2/blob/master/lib/omniauth/strategies/oauth2.rb
      option :client_options,
             { site: secrets['documentcloud']['site'],
               authorize_url: secrets['documentcloud']['authorize_url'],
               token_url: secrets['documentcloud']['token_url'],
               callback_url: secrets['documentcloud']['callback_url'],
               ssl: { verify: !Rails.env.development? } }

      option :authorize_options, [:scope]

      uid do
        raw_info['user']['id']
      end

      info do
        {
          email: raw_info['user']['email'],
          first_name: raw_info['user']['first_name'],
          last_name: raw_info['user']['last_name'],
          # TODO: replace me with org switcher
          organization_slugs: raw_info['user']['organization_slugs']
        }
      end

      def raw_info
        # Route on Documentcloud Accounts
        @raw_info ||= access_token.get('/api/me.json').parsed
      end

      # The callback url needs to be defined here due to a regression/change
      # in omniauth https://github.com/intridea/omniauth-oauth2/issues/81
      def callback_url
        DC::SECRETS['omniauth']['documentcloud']['callback_url']
      end
    end
  end
end
