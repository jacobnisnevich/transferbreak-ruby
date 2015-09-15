require 'json'
require 'httparty'

headers = {
  :headers => {
    "X-Auth-Token" => "#{ENV['FOOTBALL_DATA_API_KEY']}"
  }
}

team_synonyms = {}

seasonDataResponse = HTTParty.get("http://www.football-data.org/alpha/soccerseasons", headers)
seasonLeagues = JSON.parse(seasonDataResponse.body)

seasonLeagues.each do |league|
  leagueName = league["caption"]
  leagueTeamsURL = league["_links"]["teams"]["href"]

  if leagueName != "Champions League 2015/16"
    leagueDataResponse = HTTParty.get(leagueTeamsURL, headers)
    leagueTeams = JSON.parse(leagueDataResponse.body)["teams"]

    leagueTeams.each do |team|
      teamName = team["name"]
      teamSynonym = team["shortName"]
      synonym_array = []
      synonym_array.push(teamSynonym)
      team_synonyms[teamName] = synonym_array
    end
  end
end

team_synonyms_json = JSON.pretty_generate(team_synonyms)

f = File.new("team_synonyms.json", "w")
f.write(team_synonyms_json)
