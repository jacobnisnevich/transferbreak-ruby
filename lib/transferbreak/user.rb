require 'mysql2'
require 'json'

class User
  def initialize()
    @client = Mysql2::Client.new(
      :adapter  => 'mysql2',
      :host     => 'jacob-aws.cksaafhhhze5.us-west-1.rds.amazonaws.com',
      :username => ENV['MYSQL_USERNAME'],
      :password => ENV['MYSQL_PASSWORD'],
      :database => 'jacob'
    )

    @default_twitter_prefs = [
      "GuillemBalague", 
      "DiMarzio", 
      "TonyEvansTimes", 
      "OliverKayTimes", 
      "OllieHoltMirror", 
      "HenryWinter"
    ]

    @default_news_prefs = [
      "The Guardian",
      "TribalFootball",
      "ESPN FC"
    ]
  end

  def createAccount(username, password, email)
    password_hash = Digest::SHA2.hexdigest password

    twitter_prefs = @default_twitter_prefs.to_json
    news_prefs = @default_news_prefs.to_json

    new_account_query = "INSERT INTO transferbreak_users (username, password_hash, email) VALUES ('#{username}', '#{password_hash}', '#{email}')"
    @client.query(new_account_query)

    new_prefs_query = "INSERT INTO transferbreak_user_preferences (username, twitter_preferences, news_preferences) VALUES ('#{username}', '#{twitter_prefs}', '#{news_prefs}')"
    @client.query(new_prefs_query)
  end

  def validateLogin(username, password) 
    password_hash = Digest::SHA2.hexdigest password
    validate_login_query = "SELECT password_hash FROM transferbreak_users WHERE username='#{username}'"
    query_output = @client.query(validate_login_query)

    validate_result = {}

    p query_output.first["password_hash"]
    p password_hash

    if query_output.first["password_hash"] == password_hash
      validate_result["valid"] = true 
    else
      validate_result["valid"] = false
    end

    validate_result
  end

  def getPreferences(username)
    get_prefs_query = "SELECT twitter_preferences, news_preferences FROM transferbreak_user_preferences WHERE username='#{username}'"
    query_output = @client.query(get_prefs_query)

    preferences_result = {}

    preferences_result["twitter"] = JSON.parse(query_output.first["twitter_preferences"])
    preferences_result["news"] = JSON.parse(query_output.first["news_preferences"])

    preferences_result
  end

  def updatePreferences(username, twitter_prefs, news_prefs)
    new_twitter_prefs = twitter_prefs.to_json
    new_news_prefs = news_prefs.to_json

    update_prefs_query = "UPDATE transferbreak_user_preferences SET twitter_preferences='#{new_twitter_prefs}', news_preferences='#{new_news_prefs}' WHERE username='jacob.nisnevich'";
    @client.query(update_prefs_query);
  end
end