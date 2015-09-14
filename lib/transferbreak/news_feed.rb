class NewsFeed
  def initialize()
    @client = Mysql2::Client.new(
      :adapter  => 'mysql2',
      :host     => 'jacob-aws.cksaafhhhze5.us-west-1.rds.amazonaws.com',
      :username => ENV['MYSQL_USERNAME'],
      :password => ENV['MYSQL_PASSWORD'],
      :database => 'jacob'
    )
  end

  def getNews(source_array)
    all_news = []

    source_array.each do |source|
      get_news_source_query = "SELECT * FROM transferbreak_articles WHERE source='#{source}'"
      news_query_result = @client.query(get_news_source_query)
      all_news = all_news.concat(news_query_result.to_a)
    end

    all_news.sort! do |a, b|
      b["date"] <=> a["date"]
    end

    latest_news = all_news[0 .. 24]

    latest_news.each do |latest_article|
      decoded_article = Base64.decode64(latest_article["title"])
      decoded_article = decoded_article.force_encoding('utf-8')
      latest_article["title"] = decoded_article

      latest_article["paragraphs"] = latest_article["paragraphs"].delete!("\n")
      latest_article["paragraphs"] = JSON.parse(latest_article["paragraphs"])

      new_array = []
      latest_article["paragraphs"].each do |paragraph|
        decoded_paragraph = Base64.decode64(paragraph)
        decoded_paragraph = decoded_paragraph.force_encoding('utf-8')
        new_array.push(decoded_paragraph)
      end

      latest_article["paragraphs"] = new_array
    end

    latest_news
  end

  def getSpecificArticle(link)
    get_specific_article_query = "SELECT * FROM transferbreak_articles WHERE link='#{link}'"

    articleData = @client.query(get_specific_article_query)
    articleData = articleData.first

    decoded_article = Base64.decode64(articleData["title"])
    decoded_article = decoded_article.force_encoding('utf-8')
    articleData["title"] = decoded_article

    articleData["paragraphs"] = articleData["paragraphs"].delete!("\n")
    articleData["paragraphs"] = JSON.parse(articleData["paragraphs"])

    new_array = []
    articleData["paragraphs"].each do |paragraph|
      decoded_paragraph = Base64.decode64(paragraph)
      decoded_paragraph = decoded_paragraph.force_encoding('utf-8')
      new_array.push(decoded_paragraph)
    end
    articleData["paragraphs"] = new_array

    articleData
  end

  def getSpecificArticleByID(id)
    get_specific_article_query = "SELECT * FROM transferbreak_articles WHERE id='#{id}'"

    articleData = @client.query(get_specific_article_query)
    articleData = articleData.first

    decoded_article = Base64.decode64(articleData["title"])
    decoded_article = decoded_article.force_encoding('utf-8')
    articleData["title"] = decoded_article

    articleData["paragraphs"] = articleData["paragraphs"].delete!("\n")
    articleData["paragraphs"] = JSON.parse(articleData["paragraphs"])

    new_array = []
    articleData["paragraphs"].each do |paragraph|
      decoded_paragraph = Base64.decode64(paragraph)
      decoded_paragraph = decoded_paragraph.force_encoding('utf-8')
      new_array.push(decoded_paragraph)
    end
    articleData["paragraphs"] = new_array

    articleData
  end
end