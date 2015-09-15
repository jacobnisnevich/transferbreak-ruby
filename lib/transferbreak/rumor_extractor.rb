class RumorExtractor
  def initialize(paragraphs)
    @paragraphs = paragraphs

    StanfordCoreNLP.jar_path = Dir.pwd + '/lib/transferbreak/stanford-nlp-models/'
    StanfordCoreNLP.model_path = Dir.pwd + '/lib/transferbreak/stanford-nlp-models/'
    @pipeline = StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)

    @client = Mysql2::Client.new(
      :adapter  => 'mysql2',
      :host     => 'jacob-aws.cksaafhhhze5.us-west-1.rds.amazonaws.com',
      :username => ENV['MYSQL_USERNAME'],
      :password => ENV['MYSQL_PASSWORD'],
      :database => 'jacob'
    )

    @descriptors = [
      # Position
      "defender",
      "attacking midfielder",
      "central midfielder",
      "centre back",
      "centre forward",
      "defensive midfielder",
      "keeper",
      "left midfielder",
      "left winger",
      "left-back",
      "left back",
      "right midfielder",
      "right winger",
      "right-back",
      "right back",
      "secondary striker",
      "second striker",
      "winger",
      "striker",
      "center back",
      "center half",
      "centre half",
      "center-half",
      "centre-half",
      "center forward",
      "holding midfielder",
      "midfielder",
      # Other
      "youngster",
      "youth",
      "teenager",
      "talent"
    ]

    @interest = [
      "tracking",
      "interested in",
      "interest in",
      "keeping tabs on",
      "pursuing",
      "battling for",
      "made a push for",
      "making a push for",
      "subject of interest",
      "on the radar",
      "prepared to pay",
      "prepared to bid",
      "made a summer push for"
    ]

    @interesting_tags = [
      "ORGANIZATION",
      "LOCATION",
      "PERSON",
      "MONEY"
    ]
  end

  def getRumors()
    paragraph_rumors = []

    @paragraphs.each do |paragraph|
      tagged_text = getNERTaggedText(paragraph)
      tagged_text_merged = mergeAdjacentXMLTags(tagged_text)

      extracted_target = extractTarget(tagged_text_merged)
      player_target = extracted_target["player_target"] || extracted_target
      replaced_text = extracted_target["replaced_text"]

      extracted_destination = extractDestination(replaced_text)
      extracted_fee = extractFee(replaced_text)

      combined_rumor = {}
      if extracted_target["error"].nil?
        combined_rumor.merge!(player_target)
      end
      if extracted_destination["error"].nil?
        combined_rumor.merge!(extracted_destination)
      end
      if extracted_fee["error"].nil?
        combined_rumor.merge!(extracted_fee)
      end

      paragraph_rumors.push(combined_rumor)
    end

    paragraph_rumors = mergeSimilarRumors(paragraph_rumors)
    paragraph_rumors = nullifyEmptyFields(paragraph_rumors)
    paragraph_rumors = verifyPlayersAndTeams(paragraph_rumors)

    paragraph_rumors
  end

  private

  def getNERTaggedText(paragraph)
    ner_tags = []

    tagged_text = paragraph

    paragraph = StanfordCoreNLP::Annotation.new(paragraph)
    @pipeline.annotate(paragraph)

    paragraph.get(:sentences).each do |sentence|
      sentence.get(:tokens).to_a.each_with_index do |token, index|
        tag = token.get(:named_entity_tag).to_s

        if @interesting_tags.include?(tag)
          ner_tags.push({
            "tag" => tag,
            "offset_start" => token.get(:character_offset_begin).to_s,
            "offset_end" => token.get(:character_offset_end).to_s
          })
        end
      end
    end

    ner_tags = ner_tags.sort_by{ |hash| Integer(hash['offset_start']) }.reverse

    ner_tags.each do |entity|
      tagged_text.insert(Integer(entity["offset_end"]), "</#{entity['tag']}>")
      tagged_text.insert(Integer(entity["offset_start"]), "<#{entity['tag']}>")
    end

    tagged_text
  end

  def mergeSimilarRumors(rumors_array)
    rumors_array.each do |rumor|
      rumors_array.each do |rumor_inner|
        if rumor["player"] == rumor_inner["player"]
          rumor.merge!(rumor_inner)
        end
      end
    end

    rumors_array
  end

  def nullifyEmptyFields(rumors_array)
    rumors_array.each do |rumor|
      if rumor["player"] == ''
        rumor["player"] = nil
      end
      if rumor["from"] == ''
        rumor["from"] = nil
      end
      if rumor["to"] == []
        rumor["to"] = nil
      end
      if rumor["fee"] == ''
        rumor["fee"] = nil
      end
    end

    rumors_array
  end

  def verifyPlayersAndTeams(rumors_array)
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

    rumors_array.each do |rumor|
      if !rumor["player"].nil?
        match = FuzzyMatch.new(player_names).find(rumor["player"], {:find_with_score => true})
        if !match.nil?
          if match[1] > 0.9 && match[2] > 0.9
            rumor["player"] = player_name_synonyms[match[0]]
          end
        end
      end
      if !rumor["from"].nil?
        match = FuzzyMatch.new(team_names).find(rumor["from"], {:find_with_score => true})
        if !match.nil?
          if match[1] > 0.8 && match[2] > 0.8
            rumor["from"] = team_name_synonyms[match[0]]
          end
        end
      end
      if !rumor["to"].nil?
        rumor["to"].each do |destination|
          match = FuzzyMatch.new(team_names).find(destination, {:find_with_score => true})
          if !match.nil?
            if match[1] > 0.8 && match[2] > 0.8
              destination = team_name_synonyms[match[0]]
            end
          end
        end
      end
    end

    rumors_array
  end

  def mergeAdjacentXMLTags(text)
    merged_text = text.gsub("</LOCATION>", "</ORGANIZATION>")
    merged_text = merged_text.gsub("<LOCATION>", "<ORGANIZATION>")
    merged_text = merged_text.gsub("</ORGANIZATION> <ORGANIZATION>", " ")
    merged_text = merged_text.gsub("</ORGANIZATION><ORGANIZATION>", "")
    merged_text = merged_text.gsub("</PERSON> <PERSON>", " ")
    merged_text = merged_text.gsub("</PERSON><PERSON>", "")
    merged_text = merged_text.gsub("</MONEY> <MONEY>", " ")
    merged_text = merged_text.gsub("</MONEY><MONEY>", "")
  end

  def extractTarget(text)
    player_target = {}
    replaced_text = text;

    matchData = /<PERSON>(.*?)<\/PERSON>.*at <ORGANIZATION>([^<|>]*?)<\/ORGANIZATION>/.match(text)
    if !matchData.nil?
      player_target = {
        "player" => matchData[1],
        "from" => matchData[2]
      }
      replaced_text.gsub!(/<PERSON>(.*?)<\/PERSON>.*at <ORGANIZATION>([^<|>]*?)<\/ORGANIZATION>/, "<TARGET></TARGET>")
    else 
      matchData = /<ORGANIZATION>([^<|>]*?)<\/ORGANIZATION>'s <PERSON>(.*?)<\/PERSON>/.match(text)
      if !matchData.nil?
        player_target = {
          "player" => matchData[2],
          "from" => matchData[1]
        }
        replaced_text.gsub!(/<ORGANIZATION>([^<|>]*?)<\/ORGANIZATION>'s <PERSON>(.*?)<\/PERSON>/, "<TARGET></TARGET>")
      else
        matching_regex = //
        @descriptors.each do |descriptor|
          matching_regex = /<ORGANIZATION>([^<|>]*?)<\/ORGANIZATION> #{descriptor} <PERSON>(.*?)<\/PERSON>/
          matchData = matching_regex.match(text)
          break if !matchData.nil?
        end
        if !matchData.nil?
          player_target = {
            "player" => matchData[2],
            "from" => matchData[1]
          }
          replaced_text.gsub!(matching_regex, "<TARGET></TARGET>")
        else
          return {"error" => "no match", "replaced_text" => replaced_text }
        end
      end
    end

    { "player_target" => player_target, "replaced_text" => replaced_text }
  end

  def extractDestination(text)
    destination = {}

    matchData = //.match(text)
    matching_regex = //

    @interest.each do |interest_text|
      matching_regex = /<ORGANIZATION>(.*?)<\/ORGANIZATION> and <ORGANIZATION>(.*?)<\/ORGANIZATION>.*?#{interest_text}.*?<TARGET><\/TARGET>/
      matchData = matching_regex.match(text)
      break if !matchData.nil?
    end
    if !matchData.nil?
      destination = {
        "to" => [
          matchData[1],
          matchData[2],
        ]
      }
    else
      @interest.each do |interest_text|
        matching_regex = /<ORGANIZATION>(.*?)<\/ORGANIZATION>.*?#{interest_text}.*?<TARGET><\/TARGET>/
        matchData = matching_regex.match(text)
        break if !matchData.nil?
      end
      if !matchData.nil?
        destination = {
          "to" => [
            matchData[1]
          ]
        }
      else
        @interest.each do |interest_text|
          matching_regex = /<TARGET><\/TARGET>.*?#{interest_text}.*?<ORGANIZATION>(.*?)<\/ORGANIZATION> and <ORGANIZATION>(.*?)<\/ORGANIZATION>/
          matchData = matching_regex.match(text)
          break if !matchData.nil?
        end
        if !matchData.nil?
          destination = {
            "to" => [
              matchData[1],
              matchData[2]
            ]
          }
        else
          @interest.each do |interest_text|
            matching_regex = /<TARGET><\/TARGET>.*?#{interest_text}.*?<ORGANIZATION>(.*?)<\/ORGANIZATION>/
            matchData = matching_regex.match(text)
            break if !matchData.nil?
          end
          if !matchData.nil?
            destination = {
              "to" => [
                matchData[1]
              ]
            }
          else
            @interest.each do |interest_text|
              matching_regex = /<ORGANIZATION>(.*?)<\/ORGANIZATION>.*?#{interest_text}.*?<PERSON>([^<|>]*?)<\/PERSON>/
              matchData = matching_regex.match(text)
              break if !matchData.nil?
            end
            if !matchData.nil?
              destination = {
                "to" => [
                  matchData[1]
                ],
                "player" => matchData[2]
              }
            else
              @interest.each do |interest_text|
                matching_regex = /<ORGANIZATION>(.*?)<\/ORGANIZATION> and <ORGANIZATION>(.*?)<\/ORGANIZATION>.*?#{interest_text}.*?<PERSON>([^<|>]*?)<\/PERSON>/
                matchData = matching_regex.match(text)
                break if !matchData.nil?
              end
              if !matchData.nil?
                destination = {
                  "to" => [
                    matchData[1],
                    matchData[2]
                  ],
                  "player" => matchData[3]
                }
              else
                return {"error" => "no match"}
              end
            end
          end
        end
      end
    end

    destination
  end

  def extractFee(text)
    fee = { "error" => "no match"}

    text_parsed = text.gsub(" million", "m")

    matchData = /<MONEY>([^<|>]*?)<\/MONEY>/.match(text_parsed)

    if !matchData.nil?
      fee = {
        "fee" => Monetize.parse(matchData[1].sub("£", " GBP ").sub("€", " EUR ")).format,
      }
    end

    fee
  end

end