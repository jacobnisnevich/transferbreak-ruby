require 'json'
require 'time'
require 'base64'
require 'byebug'

require 'mysql2'
require 'twitter'

require 'stanford-core-nlp'
require 'monetize'
require 'fuzzy_match'

require 'nokogiri'
require 'open-uri'

require File.expand_path("../transferbreak/env.rb", __FILE__) if File.exists?(File.expand_path("../transferbreak/env.rb", __FILE__))

[
  'user.rb',
  'twitter_feed.rb',
  'news_feed.rb',
  'football_data.rb',
  'news_parser.rb',
  'article_parser.rb',
  'tribalfootball_parser.rb'
].each do |file_name|
  require File.expand_path("../transferbreak/#{file_name}", __FILE__)
end
