require 'mysql2'
require 'json'

class FootballData
  def initialize()
    @client = Mysql2::Client.new(
      :adapter  => 'mysql2',
      :host     => 'jacob-aws.cksaafhhhze5.us-west-1.rds.amazonaws.com',
      :username => ENV['MYSQL_USERNAME'],
      :password => ENV['MYSQL_PASSWORD'],
      :database => 'jacob'
    )
  end

  def getPlayers(query)
    player_lookup_query = "SELECT p.name, p.team, t.logo FROM transferbreak_players AS p, transferbreak_teams AS t WHERE p.name LIKE '%#{query}%' AND p.team = t.team"
    @client.query(player_lookup_query).to_a
  end

  def getSpecificPlayer(name, team)
    player_lookup_query = "SELECT p.*, t.logo FROM transferbreak_players AS p, transferbreak_teams AS t WHERE p.name LIKE '%#{name}%' AND p.team = t.team AND t.team LIKE '%#{team}%'"
    @client.query(player_lookup_query).first
  end
end