require 'mysql2'
require 'json'

@client = Mysql2::Client.new(
  :adapter  => 'mysql2',
  :host     => 'jacob-aws.cksaafhhhze5.us-west-1.rds.amazonaws.com',
  :username => ENV['MYSQL_USERNAME'],
  :password => ENV['MYSQL_PASSWORD'],
  :database => 'jacob'
)

all_player_names = @client.query("SELECT name FROM transferbreak_players")

player_synonyms = {}

all_player_names.each do |name|
  player_synonyms[name["name"]] = nil
end

player_synonyms_json = JSON.pretty_generate(player_synonyms)

f = File.new("player_synonyms.json", "w")
f.write(player_synonyms_json)
