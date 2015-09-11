require 'nokogiri'
require 'open-uri'

class NewsParser
  def initialize(url, source)
    @newsSite =  Nokogiri::HTML(open(url))
    @newsSource = source

    @articleUrls = []
    @articleDataArray = []
  end

  def parseArticles()
    @articleDataArray.each do |articleData|
      articleParser = ArticleParser.new(articleData, @newsSource)
      articleParser.parseAndStore
    end
  end
end