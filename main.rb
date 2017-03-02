require 'sinatra'
require 'json'
require './key_server.rb'

key_server = KeyServer.new

Thread.new do 
  while true do
     sleep 1
     key_server.cleanup
  end
end

put '/key/create' do
  content_type :json
  { :key => key_server.create, :msg => 'key generated' }.to_json
end

get '/key/fetch_available_one' do
  key = key_server.fetch_available_one
  status key.nil? ? 404 : 200
  msg = key.nil? ? "Not available" : "fetched successfully"
  content_type :json
  { :key => key, :msg => msg }.to_json
end

post '/key/unblock/:key' do
  key = params[:key]
  key_server.unblock key
  content_type :json
  {key: key, :msg => "unblocked successfully" }.to_json
end

delete '/key/delete/:key' do
  key = params[:key]
  key_server.delete(key)
  content_type :json
  {key: key, :msg => "deleted successfully" }.to_json
end

post '/key/keep_alive/:key' do
  key = params[:key]
  key_server.keep_alive key
  content_type :json
  {key: key, :msg => "ttl increased by 5 minute" }.to_json
end

get '/key/getall' do
  content_type :json
  key_server.getall.to_json
end
