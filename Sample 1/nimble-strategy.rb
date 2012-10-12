require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Nimble < OmniAuth::Strategies::OAuth2
      option :name, "nimble"
      
      option :client_options, {
        :site => "https://api.nimble.com",
        :authorize_url => '/oauth/authorize',
        :token_url => '/oauth/token'
      }
      
      option :provider_ignores_state, true

    end
  end
end
