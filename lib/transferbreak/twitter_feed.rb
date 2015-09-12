require 'twitter'
require 'time'

class TwitterFeed
  def initialize()
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_SECRET"]
    end
  end

  def getTweets(user_array)
    all_tweets = []

    user_array.each do |user|
      tweets = @client.user_timeline(user)
      tweets.each do |tweet| 
        new_tweet = {}

        new_tweet["user"] = user
        new_tweet["name"] = tweet.user.name
        new_tweet["url"] = tweet.uri.to_s
        new_tweet["text"] = tweet.full_text
        new_tweet["profile"] = tweet.user.profile_image_url_https.to_s
        new_tweet["date"] = tweet.created_at

        all_tweets.push(new_tweet)
      end
    end

    all_tweets.sort! do |a, b|
      b["date"] <=> a["date"]
    end

    all_tweets[0 .. 24]
  end

  def getNewTweets(user_array, newest_date)
    all_tweets = getTweets(user_array)

    newer_tweets = all_tweets.select do |x|
      x["date"] > Time.parse(newest_date)
    end

    newer_tweets
  end
end