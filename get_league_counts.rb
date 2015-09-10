require "httparty"
require "json"

headers = {
  :headers => {
    "X-Auth-Token" => "#{ENV['FOOTBALL_DATA_API_KEY']}"
  }
}

seasonDataResponse = HTTParty.get("http://www.football-data.org/alpha/soccerseasons", headers)
seasonLeagues = JSON.parse(seasonDataResponse.body)

seasonLeagues.each do |league|
  leagueName = league["caption"]
  leagueTeamsURL = league["_links"]["teams"]["href"]

  leagueDataResponse = HTTParty.get(leagueTeamsURL, headers)
  leagueTeams = JSON.parse(leagueDataResponse.body)["teams"]

  p "#{leagueName}: #{leagueTeams.count}" 
end
