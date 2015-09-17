require 'sinatra'
require 'json'

require File.expand_path('../lib/transferbreak.rb', __FILE__)

enable :sessions

Thread.abort_on_exception = true
Thread.new do  
  while true do
    tribalFootballParser = TribalFootballParser.new
    tribalFootballParser.parseArticles
    sleep 900
  end
end

get '/' do
  session["user"] ||= nil
  File.read(File.join('public', 'index.html'))
end

# Sessions

get '/userLogout' do
  loggedInUser = session["user"]
  session["user"] = nil
  loggedInUser.to_json
end

get '/getLoggedInUser' do
  responseJSON = {}  
  if session["user"] != nil
    responseJSON["loggedIn"] = true
    responseJSON["user"] = session["user"]
  else 
    responseJSON["loggedIn"] = false
    responseJSON["user"] = nil
  end
  responseJSON.to_json
end

# User

post '/createAccount' do
  user = User.new
  parameters = JSON.parse(request.body.read)
  session["user"] = parameters["username"]
  user.createAccount(parameters["username"], parameters["password"], parameters["email"])
end

post '/validateLogin' do
  user = User.new
  parameters = JSON.parse(request.body.read)
  validateResult = user.validateLogin(parameters["username"], parameters["password"])
  if validateResult["valid"] == true
    session["user"] = parameters["username"]
  end
  validateResult.to_json
end

post '/getUserPreferences' do
  user = User.new
  parameters = JSON.parse(request.body.read)
  user.getPreferences(parameters["username"]).to_json
end

post '/updateUserPreferences' do 
  user = User.new
  parameters = JSON.parse(request.body.read)
  user.updatePreferences(parameters["username"], parameters["twitterPrefs"], parameters["newsPrefs"])
end

# Twitter

post '/getTwitterFeed' do
  twitterFeed = TwitterFeed.new
  parameters = JSON.parse(request.body.read)
  twitterFeed.getTweets(parameters["twitterUsers"]).to_json
end

post '/getNewTweets' do
  twitterFeed = TwitterFeed.new
  parameters = JSON.parse(request.body.read)
  twitterFeed.getNewTweets(parameters["twitterUsers"], parameters["newestDate"]).to_json
end

post '/getProfilePage' do
  twitterFeed = TwitterFeed.new
  parameters = JSON.parse(request.body.read)
  twitterFeed.getUserPage(parameters["user"]).to_json
end

# News Articles

post '/getNewsFeed' do
  newsFeed = NewsFeed.new
  parameters = JSON.parse(request.body.read)
  newsFeed.getNews(parameters["newsSources"]).to_json
end

post '/getNewNews' do
  newsFeed = NewsFeed.new
  parameters = JSON.parse(request.body.read)
  newsFeed.getNewNews(parameters["newsSources"], parameters["newestDate"]).to_json
end

post '/getSpecificArticle' do
  newsFeed = NewsFeed.new
  parameters = JSON.parse(request.body.read)
  newsFeed.getSpecificArticle(parameters["link"]).to_json
end

post '/getSpecificArticleByID' do
  newsFeed = NewsFeed.new
  parameters = JSON.parse(request.body.read)
  newsFeed.getSpecificArticleByID(parameters["id"]).to_json
end

post '/getNewNews' do # TODO
  newsFeed = NewsFeed.new
  parameters = JSON.parse(request.body.read)
  newsFeed.getNewNews(parameters["newsSources"], parameters["newestDate"]).to_json
end

# Player Search

post '/lookUpPlayer' do
  footballData = FootballData.new
  parameters = JSON.parse(request.body.read)
  footballData.getPlayers(parameters["query"]).to_json
end

post '/getSpecificPlayer' do
  footballData = FootballData.new
  parameters = JSON.parse(request.body.read)
  footballData.getSpecificPlayer(parameters["name"], parameters["team"]).to_json
end

post '/getSpecificPlayerWithoutTeam' do
  footballData = FootballData.new
  parameters = JSON.parse(request.body.read)
  footballData.getSpecificPlayerWithoutTeam(parameters["name"]).to_json
end

# Team Search

post '/lookUpTeam' do
  footballData = FootballData.new
  parameters = JSON.parse(request.body.read)
  footballData.getTeams(parameters["query"]).to_json
end

post '/getSpecificTeam' do
  footballData = FootballData.new
  parameters = JSON.parse(request.body.read)
  footballData.getSpecificTeam(parameters["team"]).to_json
end
