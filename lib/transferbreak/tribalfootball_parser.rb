class TribalFootballParser < NewsParser
  def initialize()
    super("http://www.tribalfootball.com/transfers", "Tribal Football")
  end

  def parseArticles()
    getArticlesList()
    getArticleData()

    super
  end

  private

  def getArticlesList()
    articleLinks = @newsSite.css(".switcher.js-anchor.list .grid .grid__item a")
    articleLinks.each do |articleLink|
      @articleUrls.push("http://www.tribalfootball.com#{articleLink["href"]}")
    end
  end

  def getArticleData()
    @articleUrls.each do |articleUrl|
      article = Nokogiri::HTML(open(articleUrl))
      articleData = {}

      articleData["link"] = articleUrl
      articleData["title"] = article.css(".article__title[itemprop='headline']").text
      articleData["author"] = article.css(".article__meta a[rel='author']").text
      articleData["date"] = Time.new(article.css(".article__meta time[itemprop='datePublished']").attribute("datetime").value).to_s
      articleData["paragraphs"] = []
      article.css("[itemprop='articleBody'] p").each do |articleParagraph|
        articleData["paragraphs"].push(articleParagraph.text)
      end
      if !article.css(".article__hero img").empty?
        articleData["image"] = article.css(".article__hero img").attribute("srcset").value
      end

      @articleDataArray.push(articleData)
    end
  end
end