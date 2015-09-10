require 'sinatra'
require 'json'

require File.expand_path('../lib/transferbreak.rb', __FILE__)

get '/' do
  File.read(File.join('public', 'index.html'))
end

post '/createAccount' do
  user = User.new
  parameters = JSON.parse(request.body.read)
  user.createAccount(parameters["username"], parameters["password"], parameters["email"])
end

post '/validateLogin' do
  user = User.new
  parameters = JSON.parse(request.body.read)
  user.validateLogin(parameters["username"], parameters["password"]).to_json()
end

post '/getUserPreferences' do
  user = User.new
  parameters = JSON.parse(request.body.read)
  user.getPreferences(parameters["username"]).to_json()
end

post '/updateUserPreferences' do 
  user = User.new
  parameters = JSON.parse(request.body.read)
  user.updatePreferences(parameters["username"], parameters["twitterPrefs"], parameters["newsPrefs"])
end

post '/getTwitterFeed' do
  twitterFeed = TwitterFeed.new
  parameters = JSON.parse(request.body.read)
  twitterFeed.getTweets(parameters["twitterUsers"]).to_json()
end