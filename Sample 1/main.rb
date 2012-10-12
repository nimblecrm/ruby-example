require 'sinatra'
require "net/http"
require 'json'

require_relative 'nimble-strategy'

enable :sessions

use OmniAuth::Builder do
  provider :nimble, 'API_KEY', 'SECRET_KEY', scope: "testApp"
end

get '/' do
  erb :index
end

get '/auth/nimble/callback' do
  token = request.env['omniauth.auth']['credentials']['token']
 
  uri = URI.parse("https://api.nimble.com/api/v1/contacts/list")
  args = {sort: 'recently viewed:asc', fields: 'first name,last name', access_token: token}
  
  uri.query = URI.encode_www_form(args)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(uri.request_uri)

  response = http.request(request)
  data = JSON.parse(response.body)['resources']
  
  erb :results, :locals => {:data => data}
end

get '/auth/failure' do
  erb :error, :locals => {:message => params[:message].inspect}
end