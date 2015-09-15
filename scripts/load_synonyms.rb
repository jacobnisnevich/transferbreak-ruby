require "mysql2"
require "json"

@client = Mysql2::Client.new(
  :adapter  => "mysql2",
  :host     => "jacob-aws.cksaafhhhze5.us-west-1.rds.amazonaws.com",
  :username => ENV["MYSQL_USERNAME"],
  :password => ENV["MYSQL_PASSWORD"],
  :database => "jacob"
)

@client.query("DELETE FROM transferbreak_player_synonyms")
@client.query("DELETE FROM transferbreak_team_synonyms")

# Players

player_synonyms = JSON.load(File.new("player_synonyms.json"))

player_synonyms.each do |name, synonym|
  @client.query("INSERT INTO transferbreak_player_synonyms (name, synonym) VALUES (\"#{name}\", \"#{synonym}\")")
end

# Teams

team_synonyms = JSON.load(File.new("team_synonyms.json"))

team_synonyms.each do |name, synonym|
  @client.query("INSERT INTO transferbreak_team_synonyms (name, synonym) VALUES (\"#{name}\", \"#{synonym}\")")
end