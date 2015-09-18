source 'https://rubygems.org'

# set JAVA_HOME so Heroku will install gems that need it
heroku_java_home = '/usr/lib/jvm/java-7-openjdk-amd64'
openshift_java_home = '/etc/alternatives/java_sdk_1.6.0'
ENV['JAVA_HOME'] = heroku_java_home if Dir.exist?(heroku_java_home)
ENV['JAVA_HOME'] = openshift_java_home if Dir.exist?(openshift_java_home)

gem 'sinatra'
gem 'certified'
gem 'mysql2'
gem 'twitter'
gem 'nokogiri', '1.6.7.rc3'
gem 'stanford-core-nlp'
gem 'monetize'
gem 'fuzzy_match'
gem 'byebug'
