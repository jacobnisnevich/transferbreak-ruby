require "json"

player_synonyms = JSON.load(File.new("player_synonyms.json"))

hash_of_player_synonyms = {}

player_synonyms.each do |key, value|
  hash_of_player_synonyms[key] = key
  if !value.nil?
    value.each do |synonym|
      hash_of_player_synonyms[synonym] = key
    end
  end
end

f = File.new("player_synonyms.json", "w")
f.write(JSON.pretty_generate(hash_of_player_synonyms))

team_synonyms = JSON.load(File.new("team_synonyms.json"))

hash_of_team_synonyms = {}

team_synonyms.each do |key, value|
  hash_of_team_synonyms[key] = key
  if !value.nil?
    value.each do |synonym|
      hash_of_team_synonyms[synonym] = key
    end
  end
end

f = File.new("team_synonyms.json", "w")
f.write(JSON.pretty_generate(hash_of_team_synonyms))