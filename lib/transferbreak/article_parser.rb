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

    transferRumors = extractRumors()
    transferRumors.each do |transferRumor|
      if !transferRumor["player"].nil? && transferRumor["player"] != ''
        insert_transfers_query = "INSERT IGNORE INTO transferbreak_rumors (player, `from`, `to`, fee, source, article_id, `date`) VALUES ('#{transferRumor["player"]}', '#{transferRumor["from"]}', '#{transferRumor["to"].to_json}', '#{transferRumor["fee"]}', '#{@newsSource}', '#{articleId}', '#{articleDate}' )"
        p insert_transfers_query
        @client.query(insert_transfers_query)
      end
    end

    playerAndTeamMentions = extractPlayersAndTeams()
    playerAndTeamMentions["players"].each do |player_mentioned|
      insert_player_mention_query = "INSERT IGNORE INTO transferbreak_player_mentions (article_id, player_name, source, date) VALUES ('#{articleId}', '#{player_mentioned}', '#{@newsSource}', '#{articleDate}')"
      @client.query(insert_player_mention_query)
    end
    playerAndTeamMentions["teams"].each do |team_mentioned|
      insert_team_mention_query = "INSERT IGNORE INTO transferbreak_team_mentions (article_id, team_name, source, date) VALUES ('#{articleId}', '#{team_mentioned}', '#{@newsSource}', '#{articleDate}')"
      @client.query(insert_team_mention_query)
    end

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
    player_name_synonyms = {}
    result = @client.query("SELECT * FROM transferbreak_player_synonyms")
    result.each do |player|
      player_names.push(player["name"])
      player_name_synonyms[player["name"]] = player["synonym"]
    end

    team_names = []
    team_name_synonyms = {}
    result = @client.query("SELECT * FROM transferbreak_team_synonyms")
    result.each do |team|
      team_names.push(team["name"])
      team_name_synonyms[team["name"]] = team["synonym"]
    end

    @articleData["paragraphs"].each do |paragraph|
      nerTags = getNerTags(paragraph)

      nerTags = nerTags.sort_by{ |hash| Integer(hash['offset_start']) }.reverse

      nerTags.each do |entity|
        if entity["tag"] == "ORGANIZATION" || entity["tag"] == "LOCATION"
          match = FuzzyMatch.new(team_names).find(entity["text"], {:find_with_score => true})
          if !match.nil?
            if match[1] > 0.8 && match[2] > 0.8
              data["teams"].push(team_name_synonyms[match[0]])
              paragraph = insertTeamTagAt(paragraph, team_name_synonyms[match[0]], entity["offset_start"], entity["offset_end"])
            end
          end
        elsif entity["tag"] == "PERSON"
          match = FuzzyMatch.new(player_names).find(entity["text"], {:find_with_score => true})
          if !match.nil?
            if match[1] > 0.9 && match[2] > 0.9
              data["players"].push(player_name_synonyms[match[0]])
              paragraph = insertPlayerTagAt(paragraph, player_name_synonyms[match[0]], entity["offset_start"], entity["offset_end"])
            end
          end
        end
      end
    end

    data
  end

  def extractRumors()
    transferRumors = []

    rumorExtractor = RumorExtractor.new(@articleData["paragraphs"])
    transferRumors = rumorExtractor.getRumors()

    transferRumors
  end

  def insertTeamTagAt(paragraph, team_name, offset_start, offset_end)
    paragraph = paragraph.insert(Integer(offset_end), "</a>")
    paragraph = paragraph.insert(Integer(offset_start), "<a class='entity-mentioned' ng-click='goToTeamProfile(\"#{team_name}\"); main.currentView = \"search\"'>")
    paragraph
  end

  def insertPlayerTagAt(paragraph, player_name, offset_start, offset_end)
    paragraph = paragraph.insert(Integer(offset_end), "</a>")
    paragraph = paragraph.insert(Integer(offset_start), "<a class='entity-mentioned' ng-click='goToPlayerProfile(\"#{player_name}\"); main.currentView = \"search\"'>")
    paragraph
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
      nerTags.push(combined_text_hash)
    elsif tag == "ORGANIZATION" || tag == "LOCATION" || tag == "PERSON"
      combined_text_hash = {
        "text" => combined_text,
        "offset_start" => offset_start,
        "offset_end" => offset_end,
        "tag" => tag
      }
      nerTags.push(combined_text_hash)
    end

    nerTags
  end
end