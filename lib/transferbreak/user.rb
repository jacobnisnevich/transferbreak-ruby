require 'mysql2'

class User
  def initialize()
    @client = Mysql2::Client.new(
      :adapter  => 'mysql2',
      :host     => 'jacob-aws.cksaafhhhze5.us-west-1.rds.amazonaws.com',
      :username => ENV['MYSQL_USERNAME'],
      :password => ENV['MYSQL_PASSWORD'],
      :database => 'jacob'
    )
  end

  def createAccount(username, password, email)
    password_hash = Digest::SHA2.hexdigest password
    new_account_query = "INSERT INTO transferbreak_users (username, password_hash, email) VALUES ('#{username}', '#{password_hash}', '#{email}')"
    @client.query(new_account_query)
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
end