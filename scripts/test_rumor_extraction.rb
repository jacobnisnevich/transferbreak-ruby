require 'stanford-core-nlp'
require 'monetize'

StanfordCoreNLP.jar_path = File.expand_path('..') + '/lib/transferbreak/stanford-nlp-models/'
StanfordCoreNLP.model_path = File.expand_path('..') + '/lib/transferbreak/stanford-nlp-models/'
pipeline = StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma, :parse, :ner, :dcoref)

DESCRIPTORS = [
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

INTEREST = [
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

INTERESTING_TAGS = [
  "ORGANIZATION",
  "LOCATION",
  "PERSON",
  "MONEY"
]

PARAGRAPHS = [
  "Real Madrid are believed to be showing significant interest in Everton's John Stones.",
  "Spanish clubs Valencia and Atletico Madrid are believed to be tracking Nathan Oduwa's form at Rangers for $46 million.",
  "Bolton and Cardiff City are showing interest in Manchester United's James Wilson.",
  "Manchester United were reportedly prepared to pay a record-breaking transfer fee for Bayern Munich's Thomas Muller.",
  "Arsenal are reportedly keeping tabs on Anderlecht midfielder Youri Tielemans and may table a bid for the teenager once the January transfer window opens.",
  "Newcastle United are still interested in Queens Park Rangers striker Charlie Austin, according to Toon boss Steve McClaren.",
  "Burnley defender Michael Keane is reportedly the subject of interest from Newcastle United and Everton.",
  "Birmingham winger Demarai Gray is reportedly on the radar of German Champions Bayern Munich.",
  "Inter Milan chief Piero Ausilio insists they were never interested in Mario Balotelli.",
  "Liverpool and Manchester United are battling for Brazilian teenager Fabricio Oya.",
  "Manchester City boss Manuel Pellegrini is coy over whether they made a summer push for Juventus midfielder Paul Pogba."
]

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
      DESCRIPTORS.each do |descriptor|
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

  INTEREST.each do |interest_text|
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
    INTEREST.each do |interest_text|
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
      INTEREST.each do |interest_text|
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
        INTEREST.each do |interest_text|
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
          INTEREST.each do |interest_text|
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
            INTEREST.each do |interest_text|
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

f = File.new("test_rumor_out.txt", "w")

PARAGRAPHS.each_with_index do |paragraph, index|
  ner_tags = []

  tagged_text = paragraph

  paragraph = StanfordCoreNLP::Annotation.new(paragraph)
  pipeline.annotate(paragraph)

  paragraph.get(:sentences).each do |sentence|
    sentence.get(:tokens).to_a.each_with_index do |token, index|
      tag = token.get(:named_entity_tag).to_s

      if INTERESTING_TAGS.include?(tag)
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

  f.write("#{index + 1}. #{paragraph}")
  f.write("\n")
  f.write("Tagged Text\n")
  f.write("\t" + tagged_text)
  f.write("\n")
  f.write("Tagged Text (Merged Adjacent)\n")
  f.write("\t" + tagged_text_merged)
  f.write("\n")
  f.write("Extracted Target\n")
  f.write("\t" + player_target.to_s)
  f.write("\n")
  f.write("Target Replaced Text\n")
  f.write("\t" + replaced_text.to_s)
  f.write("\n")
  f.write("Extracted Destination\n")
  f.write("\t" + extracted_destination.to_s)
  f.write("\n")
  f.write("Extracted Fee\n")
  f.write("\t" + extracted_fee.to_s)
  f.write("\n")
  f.write("Combined Rumor\n")
  f.write("\t" + combined_rumor.to_s)
  f.write("\n\n")
  f.write("---------------------------------------------------------------------")
  f.write("\n\n")
end

f.close 
