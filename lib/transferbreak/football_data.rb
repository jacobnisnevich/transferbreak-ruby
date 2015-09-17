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

  # Players

  def getPlayers(query)
    player_lookup_query = "SELECT p.name, p.team, t.logo FROM transferbreak_players AS p, transferbreak_teams AS t WHERE p.name LIKE '%#{query}%' AND p.team = t.team"
    @client.query(player_lookup_query).to_a
  end

  def getSpecificPlayer(name, team)
    player_lookup_query = "SELECT p.*, t.logo FROM transferbreak_players AS p, transferbreak_teams AS t WHERE p.name LIKE '%#{name}%' AND p.team = t.team AND t.team LIKE '%#{team}%'"
    player_info = @client.query(player_lookup_query).first

    player_mentions_query = "SELECT DISTINCT m.*, a.link, a.title FROM transferbreak_player_mentions AS m, transferbreak_articles AS a WHERE m.player_name = '#{name}' AND a.id = m.article_id"
    player_mentions = @client.query(player_mentions_query).to_a

    player_mentions.each do |mention|
      mention["title"] = Base64.decode64(mention["title"])
    end

    return_object = {}
    return_object["player_info"] = player_info
    return_object["player_mentions"] = player_mentions

    return_object
  end

  def getSpecificPlayerWithoutTeam(name)
    player_lookup_query = "SELECT p.*, t.logo FROM transferbreak_players AS p, transferbreak_teams AS t WHERE p.name LIKE '%#{name}%' AND p.team = t.team"
    player_info = @client.query(player_lookup_query).first

    player_mentions_query = "SELECT DISTINCT m.*, a.link, a.title FROM transferbreak_player_mentions AS m, transferbreak_articles AS a WHERE m.player_name = '#{name}' AND a.id = m.article_id"
    player_mentions = @client.query(player_mentions_query).to_a

    player_mentions.each do |mention|
      mention["title"] = Base64.decode64(mention["title"])
    end

    return_object = {}
    return_object["player_info"] = player_info
    return_object["player_mentions"] = player_mentions

    return_object
  end

  # Teams

  def getTeams(query)
    team_lookup_query = "SELECT * FROM transferbreak_teams WHERE team LIKE '%#{query}%'"
    @client.query(team_lookup_query).to_a
  end

  def getSpecificTeam(team)
    team_lookup_query = "SELECT t.*, l.nation FROM transferbreak_leagues AS l, transferbreak_teams AS t WHERE t.team LIKE '%#{team}%' AND l.league = t.league"
    team_info = @client.query(team_lookup_query).first

    team_mentions_query = "SELECT DISTINCT m.*, a.link, a.title FROM transferbreak_team_mentions AS m, transferbreak_articles AS a WHERE m.team_name = '#{team}' AND a.id = m.article_id"
    team_mentions = @client.query(team_mentions_query).to_a

    team_mentions.each do |mention|
      mention["title"] = Base64.decode64(mention["title"]).force_encoding('utf-8')
    end

    team_roster_query = "SELECT * FROM transferbreak_players WHERE team = '#{team}'"
    team_roster = @client.query(team_roster_query).to_a

    byebug

    return_object = {}
    return_object["team_info"] = team_info
    return_object["team_mentions"] = team_mentions
    return_object["team_roster"] = team_roster

    return_object
  end
end