# Copyright 2012 Nimble
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

require 'sinatra'
require 'json'
require 'oauth2'
require 'faraday'

# fill your own parameters
CLIENT_ID = '6a0694f589ed960d13722c7a017dc3cc'
CLIENT_SECRET = 'bbaaf3fe1ff3c5ee'
CALLBACK_PATH = '/auth/nimble/callback'

def client
    OAuth2::Client.new(CLIENT_ID, CLIENT_SECRET, 
      :site => 'https://api.nimble.com',
    )
end

def redirect_uri()
  uri = URI.parse(request.url)
  uri.path = CALLBACK_PATH
  uri.query = nil
  uri.to_s
end

get '/' do
  @redirect_to = client.auth_code.authorize_url(:redirect_uri => redirect_uri)
  erb :index
end

get '/auth/nimble/callback' do
  # configure access token
  token_opts = {
    :mode => :query,
    :param_name => :access_token,
  }
  access_token = client.auth_code.get_token(params[:code], {:redirect_uri => redirect_uri}, token_opts)
  # ask Nomble to return data about currently logged user
  user_info = access_token.get('/api/users/myself/', {:parse => :json}).parsed
  # ask recently viewed contacts
  args = {:sort => 'recently viewed:asc', :fields => 'first name,last name'}
  response = access_token.get('/api/v1/contacts/list', {:params => args, :parse => :json}).parsed

  erb :results, :locals => {:data => response['resources'], :name => user_info['name']}
end

get '/auth/failure' do
  erb :error, :locals => {:message => params[:message].inspect}
end