# Copyright 2012 Nimble
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

require 'sinatra'
require 'json'
require 'faraday'
require 'omniauth-nimble'

# fill your own parameters
CLIENT_ID = '6a0694f589ed960d13722c7a017dc35f'
CLIENT_SECRET = 'eeaaf3fe1ff3c5aa'

enable :sessions

use OmniAuth::Builder do
  provider :nimble, CLIENT_ID, CLIENT_SECRET, scope: "testApp" # scope is optional
end

get '/' do
  erb :index
end

get '/auth/nimble/callback' do
  token = request.env['omniauth.auth']['credentials']['token']
  # we got name of logged user
  name = request.env['omniauth.auth']['info']['name']
 
  # make request to Nimble API
  args = {sort: 'recently viewed:asc', fields: 'first name,last name', access_token: token}  
  conn = Faraday.new('https://api.nimble.com')
  response = conn.get '/api/v1/contacts/list', args
  data = JSON.parse(response.body)['resources']
  
  erb :results, :locals => {:data => data, :name => name}
end

get '/auth/failure' do
  erb :error, :locals => {:message => params[:message].inspect}
end