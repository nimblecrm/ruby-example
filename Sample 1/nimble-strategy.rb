# Copyright 2012 Nimble
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

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

      uid { raw_info['email'] }

      info do
        {
          'uid'   => raw_info['email'],
          'name'  => raw_info['name'],
          'email' => raw_info['email']
        }
      end

      extra do
        { 'raw_info' => raw_info }
      end
      
      def raw_info
        access_token.options[:mode] = :query
        access_token.options[:param_name] = :access_token        
        @raw_info ||= access_token.get('/api/users/myself/', {:parse => :json}).parsed
      end
    end
  end
end
