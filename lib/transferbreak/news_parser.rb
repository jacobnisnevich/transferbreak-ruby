class NewsParser
  def initialize(url, source)
    @newsSite =  Nokogiri::HTML(open(url))
    @newsSource = source

    @articleUrls = []
    @articleDataArray = []

    @client = Mysql2::Client.new(
      :adapter  => 'mysql2',
      :host     => 'jacob-aws.cksaafhhhze5.us-west-1.rds.amazonaws.com',
      :username => ENV['MYSQL_USERNAME'],
      :password => ENV['MYSQL_PASSWORD'],
      :database => 'jacob'
    )
  end

  def parseArticles()
    @articleDataArray.each do |articleData|
      articleParser = ArticleParser.new(articleData, @newsSource)
      articleParser.parseAndStore
    end
  end
end