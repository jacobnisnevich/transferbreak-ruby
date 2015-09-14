class TribalFootballParser < NewsParser
  def initialize()
    super("http://www.tribalfootball.com/transfers", "Tribal Football")
  end

  def parseArticles()
    getArticlesList()
    getArticleData()

    newest_article_date_query = @client.query("SELECT date FROM transferbreak_articles WHERE source='#{@newsSource}' ORDER BY date DESC")
    newest_article_date = newest_article_date_query.first["date"]

    @articleDataArray = @articleDataArray.select do |articleData| 
      Time.parse(articleData["date"]) > newest_article_date
    end

    super
  end

  private

  def getArticlesList()
    articleLinks = @newsSite.css(".switcher.js-anchor.list .grid .grid__item a")

    # LOAD ALL

    articleLinks.each do |articleLink|
      @articleUrls.push("http://www.tribalfootball.com#{articleLink["href"]}")
    end

    # LOAD FIRST

    # @articleUrls.push("http://www.tribalfootball.com#{articleLinks[1]["href"]}")
  end

  def getArticleData()
    @articleUrls.each do |articleUrl|
      article = Nokogiri::HTML(open(articleUrl))
      articleData = {}

      articleData["link"] = articleUrl
      articleData["title"] = article.css(".article__title[itemprop='headline']").text
      articleData["author"] = article.css(".article__meta a[rel='author']").text
      articleData["date"] = Time.parse(article.css(".article__meta time[itemprop='datePublished']").attribute("datetime").value).to_s
      articleData["paragraphs"] = []
      article.css("[itemprop='articleBody'] p").each do |articleParagraph|
        articleData["paragraphs"].push(articleParagraph.text.force_encoding('utf-8'))
      end
      if !article.css(".article__hero img").empty?
        articleData["image"] = article.css(".article__hero img").attribute("srcset").value
      end

      @articleDataArray.push(articleData)
    end
  end
end