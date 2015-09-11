require 'mysql2'
require 'digest/sha1'


class ArticleParser
  def initialize(articleData, newsSource)
    @articleData = articleData
    @newsSource = newsSource

    @client = Mysql2::Client.new(
      :adapter  => 'mysql2',
      :host     => 'jacob-aws.cksaafhhhze5.us-west-1.rds.amazonaws.com',
      :username => ENV['MYSQL_USERNAME'],
      :password => ENV['MYSQL_PASSWORD'],
      :database => 'jacob'
    )
  end

  def parseAndStore() 
  #  transferRumors = extractRumors()
  #  transferRumors.each do |transferRumor|
  #    insert_transfers_query = "INSERT INTO transferbreak_rumors (player, from, to, fee, source) VALUES ('#{transferRumor.player}', '#{transferRumor.from}', '#{transferRumor.to}', '#{transferRumor.fee}', '#{@newsSource}')"
  #    @client.query(insert_transfers_query)
  #  end

    articleTitle = Digest::SHA1.hexdigest(@articleData['title'])
    articleAuthor = @articleData['author']
    articleDate = @articleData['date']
    articleImage = @articleData['image']
    articleParagraphHashes = []
    @articleData["paragraphs"].each do |paragraph|
      articleParagraphHashes.push(Digest::SHA1.hexdigest(paragraph))
    end
    articleParagraphsString = articleParagraphHashes.to_json
    articleLink = @articleData['link']

    insert_article_data = "INSERT INTO transferbreak_articles (source, title, author, date, image, paragraphs, link) VALUES ('#{@newsSource}', '#{articleTitle}', '#{articleAuthor}', '#{articleDate}', '#{articleImage}', '#{articleParagraphsString}', '#{articleLink}')"

    begin
      @client.query(insert_article_data)
    rescue
      error = "Article already exists"
    end
  end

  def extractRumors()
    transferRumors = []

    @articleData.paragraphs.each do |paragraph|
      # Get from, to, fee, player
    end

    transferRumors
  end
end