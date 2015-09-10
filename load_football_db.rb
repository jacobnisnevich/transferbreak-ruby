require "httparty"
require "json"
require "mysql2"

client = Mysql2::Client.new(
  :adapter  => "mysql2",
  :host     => "jacob-aws.cksaafhhhze5.us-west-1.rds.amazonaws.com",
  :username => ENV["MYSQL_USERNAME"],
  :password => ENV["MYSQL_PASSWORD"],
  :database => "jacob"
)

headers = {
  :headers => {
    "X-Auth-Token" => "#{ENV['FOOTBALL_DATA_API_KEY']}"
  }
}

clearLeaguesQuery = "DELETE FROM transferbreak_leagues"
clearTeamsQuery = "DELETE FROM transferbreak_teams"
clearPlayersQuery = "DELETE FROM transferbreak_players"

client.query(clearLeaguesQuery)
client.query(clearTeamsQuery)
client.query(clearPlayersQuery)

seasonDataResponse = HTTParty.get("http://www.football-data.org/alpha/soccerseasons", headers)
seasonLeagues = JSON.parse(seasonDataResponse.body)

seasonLeagues.each do |league|
  leagueName = league["caption"]
  leagueTeamsURL = league["_links"]["teams"]["href"]

  if leagueName != "Champions League 2015/16"
    leagueInsertQuery = "INSERT INTO transferbreak_leagues (league) VALUES (\"#{leagueName}\")"
    client.query(leagueInsertQuery)

    leagueDataResponse = HTTParty.get(leagueTeamsURL, headers)
    leagueTeams = JSON.parse(leagueDataResponse.body)["teams"]

    leagueTeams.each do |team|
      teamName = team["name"]
      teamLogo = team["crestUrl"]
      teamPlayersURL = team["_links"]["players"]["href"]

      teamInsertQuery = "INSERT INTO transferbreak_teams (league, team, logo) VALUES (\"#{leagueName}\", \"#{teamName}\", \"#{teamLogo}\")"
      client.query(teamInsertQuery)

      sleep(5)
      
      teamDataResponse = HTTParty.get(teamPlayersURL, headers)
      teamPlayers = JSON.parse(teamDataResponse.body)["players"]

      teamPlayers.each do |player|
        playerId = player["id"]
        playerName = player["name"]
        playerPosition = player["position"]
        playerJerseyNumber = player["jerseyNumber"]
        if player["dateOfBirth"] != nil
          playerDateOfBirth = Time.new(player["dateOfBirth"]).to_s
        end
        playerNationality = player["nationality"]
        if player["contractUntil"] != nil
          playerContractExpires = Time.new(player["contractUntil"]).to_s
        end
        playerMarketValue = player["marketValue"]

        playerInsertQuery =  "INSERT INTO transferbreak_players (name, id, team, league, position, jersey_number, date_of_birth, nationality, contract_expires, market_value) VALUES (\"#{playerName}\", \"#{playerId}\", \"#{teamName}\", \"#{leagueName}\", \"#{playerPosition}\", \"#{playerJerseyNumber}\", \"#{playerDateOfBirth}\", \"#{playerNationality}\", \"#{playerContractExpires}\", \"#{playerMarketValue}\")"
        client.query(playerInsertQuery)
      end
    end
  end
end
