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

        new_tweet["tweet_id"] = tweet.id
        new_tweet["user_id"] = tweet.user.id
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

  def getUserPage(user_id) 
    user_page = {}
    user_page["user_timeline_tweets"] = []
    user_page["user_details"] = {}

    user_timeline = @client.user_timeline(user_id)
    user = user_timeline[0].user

    user_timeline.each do |tweet|
      new_tweet = {}

      new_tweet["tweet_id"] = tweet.id
      new_tweet["user_id"] = tweet.user.id
      new_tweet["user"] = tweet.user.screen_name
      new_tweet["name"] = tweet.user.name
      new_tweet["url"] = tweet.uri.to_s
      new_tweet["text"] = tweet.full_text
      new_tweet["profile"] = tweet.user.profile_image_url_https.to_s
      new_tweet["date"] = tweet.created_at

      new_tweet["favorites_count"] = tweet.favorite_count
      new_tweet["retweets_count"] = tweet.retweet_count

      user_page["user_timeline_tweets"].push(new_tweet)
    end

    user_page["user_details"]["user_id"] = user.id
    user_page["user_details"]["name"] = user.name
    user_page["user_details"]["screen_name"] = user.screen_name
    user_page["user_details"]["description"] = user.description.to_s
    user_page["user_details"]["profile_img"] = user.profile_image_url_https.to_s
    user_page["user_details"]["background_color"] = user.profile_background_color.to_s

    user_page
  end

end