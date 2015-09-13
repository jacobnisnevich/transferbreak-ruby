require 'mysql2'
require 'base64'
require 'stanford-core-nlp'
require 'monetize'
require 'fuzzy_match'

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

    StanfordCoreNLP.jar_path = Dir.pwd + '/lib/transferbreak/stanford-nlp-models/'
    StanfordCoreNLP.model_path = Dir.pwd + '/lib/transferbreak/stanford-nlp-models/'
    @pipeline = StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)
  end

  def parseAndStore() 
    articleId = Digest::SHA2.hexdigest(@articleData['link'])
    articleDate = @articleData['date']

    data = extractPlayersAndTeams()

    data["players"].each do |player_mentioned|
      insert_player_mention_query = "INSERT INTO transferbreak_player_mentions (article_id, player_name, source, date) VALUES ('#{articleId}', '#{player_mentioned}', '#{@newsSource}', '#{articleDate}')"
      @client.query(insert_player_mention_query)
    end

    data["teams"].each do |team_mentioned|
      insert_team_mention_query = "INSERT INTO transferbreak_team_mentions (article_id, team_name, source, date) VALUES ('#{articleId}', '#{team_mentioned}', '#{@newsSource}', '#{articleDate}')"
      @client.query(insert_team_mention_query)
    end

  #  transferRumors = extractRumors()
  #  transferRumors.each do |transferRumor|
  #    insert_transfers_query = "INSERT INTO transferbreak_rumors (player, from, to, fee, source) VALUES ('#{transferRumor.player}', '#{transferRumor.from}', '#{transferRumor.to}', '#{transferRumor.fee}', '#{@newsSource}')"
  #    @client.query(insert_transfers_query)
  #  end

    articleTitle = Base64.encode64(@articleData['title'])
    articleAuthor = @articleData['author']
    articleImage = @articleData['image']
    articleParagraphHashes = []
    @articleData["paragraphs"].each do |paragraph|
      articleParagraphHashes.push(Base64.encode64(paragraph))
    end
    articleParagraphsString = articleParagraphHashes.to_json
    articleLink = @articleData['link']

    insert_article_data = "INSERT INTO transferbreak_articles (id, source, title, author, date, image, paragraphs, link) VALUES ('#{articleId}', '#{@newsSource}', '#{articleTitle}', '#{articleAuthor}', '#{articleDate}', '#{articleImage}', '#{articleParagraphsString}', '#{articleLink}')"

    begin
      @client.query(insert_article_data)
    rescue
      error = "Article already exists"
    end
  end

  def extractPlayersAndTeams()
    data = {}
    data["players"] = []
    data["teams"] = []

    player_names = []
    result = @client.query("SELECT name FROM transferbreak_players")
    result.each do |player|
      player_names.push(player["name"])
    end

    team_names = []
    result = @client.query("SELECT team FROM transferbreak_teams")
    result.each do |team|
      team_names.push(team["team"])
    end

    @articleData["paragraphs"].each do |paragraph|
      nerTags = getNerTags(paragraph)

      nerTags.sort! do |a, b| 
        b["offset_start"] <=> a["offset_start"]
      end

      nerTags.each do |entity|
        if entity["tag"] == "ORGANIZATION" || entity["tag"] == "LOCATION"
          match = FuzzyMatch.new(team_names).find(entity["text"], {:find_with_score => true})
          if !match.nil?
            if match[1] > 0.4 && match[2] > 0.4
              data["teams"].push(match[0])
              paragraph = insertTeamTagAt(paragraph, match[0], entity["offset_start"], entity["offset_end"])
            end
          end
        elsif entity["tag"] == "PERSON"
          match = FuzzyMatch.new(player_names).find(entity["text"], {:find_with_score => true})
          if !match.nil?
            if match[1] > 0.6 && match[2] > 0.6
              data["players"].push(match[0])
              paragraph = insertPlayerTagAt(paragraph, match[0], entity["offset_start"], entity["offset_end"])
            end
          end
        end
      end
    end

    data
  end

  def extractRumors()
    transferRumors = []

    @articleData["paragraphs"].each do |paragraph|
      nerTags = getNerTags(paragraph)
    end

    transferRumors
  end

  def insertTeamTagAt(paragraph, team_name, offset_start, offset_end)
    paragraph = paragraph.insert(Integer(offset_end), "</a>")
    paragraph = paragraph.insert(Integer(offset_start), "<a ng-click='goToTeamProfile(team_name)'>")
  end

  def insertPlayerTagAt(paragraph, player_name, offset_start, offset_end)
    paragraph = paragraph.insert(Integer(offset_end), "</a>")
    paragraph = paragraph.insert(Integer(offset_start), "<a ng-click='goToPlayerProfile(player_name)'>")
  end

  def getNerTags(paragraph)
    nerTags = []

    interesting_tags = [
      "ORGANIZATION",
      "LOCATION",
      "PERSON",
      "MONEY"
    ]

    paragraph = StanfordCoreNLP::Annotation.new(paragraph)
    @pipeline.annotate(paragraph)

    combined_text = ""
    prev_tag = ""
    offset_start = ""
    offset_end = ""

    paragraph.get(:sentences).each do |sentence|
      sentence.get(:tokens).to_a.each_with_index do |token, index|
        text = token.get(:original_text).to_s
        tag = token.get(:named_entity_tag).to_s

        if interesting_tags.include?(tag)
          if prev_tag == ""
            offset_start = token.get(:character_offset_begin).to_s
            combined_text = text
          else 
            if prev_tag == tag
              combined_text += " " + text
            else
              offset_end = token.get(:character_offset_begin).to_s
              nerTags = pushToTags(nerTags, prev_tag, combined_text, offset_start, offset_end)
              combined_text = text
              offset_start = token.get(:character_offset_begin).to_s
            end
          end
        else 
          offset_end = token.get(:character_offset_begin).to_s
          nerTags = pushToTags(nerTags, prev_tag, combined_text, offset_start, offset_end)
          combined_text = ""
          offset_start = token.get(:character_offset_begin).to_s
        end
        
        prev_tag = tag
      end
    end

    nerTags
  end

  def pushToTags(nerTags, tag, combined_text, offset_start, offset_end)
    combined_text_hash = {}

    if tag == "MONEY"  
      combined_text_hash = {
        "text" => Monetize.parse(combined_text.sub("£", " GBP ").sub("€", " EUR ")).format,
        "offset_start" => offset_start,
        "offset_end" => offset_end,
        "tag" => tag
      }
    else 
      combined_text_hash = {
        "text" => combined_text,
        "offset_start" => offset_start,
        "offset_end" => offset_end,
        "tag" => tag
      }
    end

    nerTags.push(combined_text_hash)

    nerTags
  end
end